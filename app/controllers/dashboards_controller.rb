class DashboardsController < ApplicationController
  before_filter :before_render
  #caches_action :chart_users, :cache_path => Proc.new { |c| c.params }, :expires_in => 6.hours
  require 'net/http'

  def index
  end

  def chart_users
    start_date, end_date = 2.weeks.ago.midnight, Time.now.utc
    rows, cols = [], [{:id => 'date',:label => "Date",:type  => "string"},
                      {:id => 'number',:label => "New Users",:type  => "number"}]
    start_date = params[:start_at].to_time if params[:start_at].present?
    end_date = params[:end_at].to_time if params[:end_at].present?
    
    while(start_date <= end_date)
      total = User.search_by({:start_at => start_date, :end_at => end_date}).count
      rows << {:c => [{ :v => start_date.strftime('%d-%b') },{:v=>total}]}
      start_date = start_date.tomorrow
    end
    
    respond_to do |format|
      format.xml  { render :xml => {:cols=>cols,:rows=>rows} }
      format.json { render :json => {:cols=>cols,:rows=>rows} }
    end
  end

  def chart_suggestion
    #feed_infos = FeedInfo.top_ten(params[:category])
    cols = [{:id => params[:category],:label => params[:category],:type  => "string"},
            {:id => 'number',:label => "Users",:type  => "number"}]
    rows = []
    #feed_infos.each do |info|
    #  rows << {:c => [{ :v => info.title },{:v=>info.follower.to_i}]}
    #end
    respond_to do |format|
      format.xml  { render :xml => {:cols=>cols,:rows=>rows} }
      format.json  { render :json => {:cols=>cols,:rows=>rows} }
    end
  end

  def ip_info
    h = Net::HTTP.new('www.ipaddressapi.com')
    response = h.get("/lookup/#{params[:ip]}")
    info = "failed to check!"
    
    if response.message == "OK"
      co = response.body.scan(/<table(\s\w+?[^=]*?="[^"]*?")*?\s+?id="(\S+?\s)*?ipinfo(\s\S+?)*?".*?>(.*?)<\/table>/ixsm)
      if co.present?
        co = co[0].join(" ").gsub(/\n/ixsm,"")
        info = co.gsub(/(<tr><th>)|(<\/th><td>)/ixsm,"").gsub(/<\/td><\/tr>/ixsm,"<br/>")
        info = info.gsub('/flags/','http://www.ipaddressapi.com/flags/')
      else
        info = ""
      end
    end
    respond_to do |format|
      format.html {render :text=>info}
    end
  end

  private
    def before_render
      @dashboard_selected = true
    end

end
