class UsersController < ApplicationController
  before_filter :before_render
  before_filter :prepare_profiles, :only => [:new,:create,:edit,:update]
  skip_before_filter :require_user, :only => [:columns]
  before_filter :user, :only => [:show, :edit]
  
  def index
    @title = Profile.find(params[:pid]).title unless params[:pid].blank?
    @users = User.filter_by(params)
    @is_content_only = params[:partial] ? true: false

    respond_to do |format|
      format.html { render :layout=> !@is_content_only}
      format.json { render :json => @users }
    end
  end

  def show
    prepare_profiles if @categories.blank?
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @user = User.new
    @is_populate = false
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def edit
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def create
    params[:user][:login] = params[:user][:email_home] = params[:user][:email_work]
    params[:user][:password] = params[:user][:password_confirmation] = generate_password if params[:user][:password].blank?
    @user = User.new(params[:user])
    @is_populate = params[:is_populate]
    @is_populate = false if @is_populate == "false"
    respond_to do |format|
      if @user.save
        cache_expiration
        start_autopopulate if @is_populate
        send_thanks_email(params[:user][:password])
        @message = "#{@user.full_name} has been created."
	      Resque.enqueue(Finforenet::Jobs::CheckPublicProfiles, @user.id) if @user.is_public
        if !request.xhr?
          format.html { redirect_to users_path({:page=>params[:page]}), :notice => @message }
        else
          @message << "You can edit now or refresh the page."
          @user.password = @user.password_confirmation = ""
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
      else
        @user.password = @user.password_confirmation = ""
        format.html { render :action => "new", :layout=> !request.xhr? }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update

    if param_user[:email_work] != user.login
      param_user[:login] = param_user[:email_work]
    end
    @selected_profiles = param_user[:profile_ids]

    respond_to do |format|
      if user.update_attributes(param_user)
        @message = "#{@user.full_name} has been modified."
	      Resque.enqueue(Finforenet::Jobs::CheckPublicProfiles, @user.id) if @user.is_public
        if !request.xhr?
          format.html { redirect_to users_path({:page=>params[:page]}), :notice => @message }
        else
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
      else
        format.html { render :action => "edit", :layout=> !request.xhr? }
      end
    end
  end

  def destroy
    user.destroy if user
    cache_expiration
    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(users_url) }
      else
        format.html { render :text=> "SUCCESS" }
      end
    end
  end

  def columns
    @accounts = user.feed_accounts
    respond_to do |format|
      format.html { 
        if params[:partial].blank?
          render :action => "show", :layout=> !request.xhr? 
        else
          format.html { render :layout=> !request.xhr? }
        end
      }
    end
  end

  def update_public
    if user
      status = user.is_public ? false : true
      user.update_attribute(:is_public,status)
    end
    respond_to do |format|
      format.html {render :text => "SUCCESS"}
    end
  end
  
  def company_tabs
    @feed_infos = CompanyCompetitor.all.map(&:feed_info).sort_by(&:title)
    @tabs = user.user_company_tabs.sort_by(&:title) if params[:page].blank?
    respond_to do |format|
      if params[:partial].blank? && params[:page].blank?
        format.html { render :action => "show", :layout=> !request.xhr? }
      elsif !params[:page].blank? && params[:page].blank?
        format.html { render :partial => "company_tabs", :layout=> !request.xhr? }
      elsif params[:page]
        format.html { render :partial => "company_tabs", :layout=> !request.xhr? }
      end
    end
    rescue => e
    respond_to do |format|
      format.html {render :text => e.to_s}
    end
  end

  def sorting_column
    if !params[:orders].blank?
      orders = params[:orders].gsub(/\,$/,"").split(",")
      counter = 1
      orders.each do |kc_id|
        item = user.feed_accounts.find(kc_id)
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

  def histories
    # @histories
  end

  private
    def user
      @user ||= User.find(params[:user_id]||params[:id])
    end

    def param_user 
      @param_user ||= params[:user]
    end

    def before_render
      @users_selected = true
    end

    def prepare_profiles
      @categories = ProfileCategory.includes(:profiles)
    end

    def send_thanks_email(password)
      UserMailer.welcome_email(@user,password).deliver
      UserMailer.new_user_to_admin(@user).deliver
    end

    def start_autopopulate
      @user.create_autopopulate
    end

    def cache_expiration  
      expire_action :action => :index
      expire_page :action => :index
    end
end
