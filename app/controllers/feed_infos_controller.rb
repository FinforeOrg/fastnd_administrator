class FeedInfosController < ApplicationController
  before_filter :before_render
  before_filter :prepare_tags, :only=>[:create,:edit,:new,:update,:index,:search,:prices]
  
  def index
    prepare_list
    respond_to do |format|
      if params[:partial].blank?
        format.html {render :layout=>!request.xhr?}
      else
        format.html {render :partial =>  "list", :layout=>!request.xhr?}
      end
      format.xml  { render :xml => @feed_infos }
    end
  end

  def search
    prepare_list
    respond_to do |format|
      if params[:partial].blank? || !request.xhr?
        format.html { render :action => :index, :layout=>!request.xhr?}
      else
        format.html {render :partial => "list", :layout=>!request.xhr?}
      end
      format.xml  { render :xml => @feed_infos }
    end
  end

  def show
    @feed_info = FeedInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed_info }
    end
  end

  def new
    @feed_info = FeedInfo.new
    @feed_info.category = "Chart" if params[:category] == "prices"
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
      format.xml  { render :xml => @feed_info }
    end
  end

  def edit
    @feed_info = FeedInfo.find(params[:id],:include=>:profiles)
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def create
    @feed_info = FeedInfo.new(params[:feed_info])

    respond_to do |format|
      if @feed_info.save
        @message = "#{@feed_info.title} has been created."
        if !request.xhr?
          format.html { redirect_to feed_infos_path({:page=>params[:page]}), :notice => @message }
        else
          @message << "You can edit now or refresh the page."
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
        format.xml  { render :xml => @feed_info, :status => :created, :location => @feed_info }
      else
        format.html { render :action => "new",:layout=>!request.xhr? }
        format.xml  { render :xml => @feed_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @feed_info = FeedInfo.find(params[:id])

    respond_to do |format|
      if @feed_info.update_attributes(params[:feed_info])
        @message = "#{@feed_info.title} has been modified."
        if !request.xhr?
          format.html { redirect_to feed_infos_path({:page=>params[:page]}), :notice => @message }
        else
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :layout=> !request.xhr?}
        format.xml  { render :xml => @feed_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @feed_info = FeedInfo.find(params[:id])
    @feed_info.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(feed_infos_url) }
      else
        format.html { render :text=> "SUCCESS" }
      end
      format.xml  { head :ok }
    end
  end

  def count_tags
    feed_info = FeedInfo.where(:_id => params[:fid]).first
    profiles = ""
    profiles = feed_info.profiles.map(&:title).join(", ") if feed_info
    respond_to do |format|
      format.html { render :text => truncate(profiles, :length => 120, :separator => "...") }
    end
  end

  def prices
    params[:filter_by] = "Chart"
    prepare_list
    respond_to do |format|
      format.html
    end
  end

  def tickers
    @feed_info = FeedInfo.includes(:price_tickers).find(params[:id])
    @tickers = @feed_info.price_tickers
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def sorting_ticker
    if !params[:orders].blank?
      orders = params[:orders].gsub(/\,$/,"").split(",")
      counter = 1
      orders.each do |kc_id|
        item = PriceTicker.find(kc_id)
        if item
          item.update_attributes({:position => counter})
          counter += 1
        end
      end
    end
    respond_to do |format|
      format.html { render :text=> "SUCCESS" }
      format.xml  { head :ok }
    end
  end

  def create_ticker
    unless params[:tickers].blank?
      tickers = params[:tickers].split(/\,|\r\n|\n/ixsm)
      tickers.each do |ticker|
        ticker = ticker.gsub(/^\s|\s$/i,"")
        PriceTicker.find_or_create_by({:feed_info_id => params[:id], :ticker => ticker}) unless ticker.blank?
      end
    end
    @feed_info = FeedInfo.includes(:price_tickers).find(params[:id])
    respond_to do |format|
      @tickers = @feed_info.price_tickers
      format.html { render :action=>:tickers, :layout=> !request.xhr?}
    end
  end

  def destroy_ticker
    ticker = PriceTicker.find params[:ticker_id]
    ticker.destroy
    respond_to do |format|
      format.html { render :text=> "SUCCESS" }
      format.xml  { head :ok }
    end
  end

  def tab_config
    info = FeedInfo.includes(:company_competitor).find(params[:id])
    if info
      company_tab = info.company_competitor
      if company_tab
        company_tab.destroy
      else
        company_tab = CompanyCompetitor.create({:feed_info_id=>params[:id]})
      end
    end
    respond_to do |format|
      if company_tab && company_tab.errors.size < 1
        format.html { render :text=> "SUCCESS" }
      else
        format.html { render :text=> "FAILED" }
      end
      format.xml  { head :ok }
    end
  end

  def populate_config
    info = FeedInfo.where(:_id => params[:id]).first
    info.update_attribute(:is_populate,info.is_populate ? false : true) if info
    respond_to do |format|
      if info
        format.html { render :text=> "SUCCESS" }
      else
        format.html { render :text=> "FAILED" }
      end
      format.xml  { head :ok }
    end
  end

  def users
    @feed_info = FeedInfo.find(params[:id])
    @users = User.contains_feed_info(@feed_info.id,params[:page]||1)
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  
  private
    def before_render
      @suggestions_selected = params[:action] !~ /price/i ? true : false
      @prices_selected = params[:action] =~ /price/i ? true : false
    end

    def prepare_tags
      @profile_categories = ProfileCategory.includes(:profiles).asc(:title)
      @info_categories = %w(Company Podcast Rss Twitter Broadcast)
    end
    
    def prepare_list(conditions = {})
      params[:page] = params[:page] || 1
      
      if !params[:Search].blank? || !params[:filter_by].blank?
        category = params[:filter_by].downcase
        category = nil if category == "all"
        conditions = {"$or" => [{:title => /#{params[:keyword]}/i}, {:address => /#{params[:keyword]}/i}]}
        conditions = FeedInfo.sectors_query(params[:profile_ids], conditions) unless params[:profile_ids].blank?
        conditions = FeedInfo.send("#{category}_query", conditions) unless category.blank?
      elsif params[:pid]
        conditions = FeedInfo.send("#{category}_query", conditions)
      end
      @feed_infos = FeedInfo.filter_feeds_data(conditions,(params[:per_page]||25), params[:page]||1)
    end

end
