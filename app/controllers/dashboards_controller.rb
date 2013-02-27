class DashboardsController < ApplicationController
  before_filter :before_render
  #caches_action :chart_users, :cache_path => Proc.new { |c| c.params }, :expires_in => 6.hours
  require 'net/http'

  def index
  end

  def chart_users
    cols = [{:id => 'date',:label => "Date",:type  => "string"},
            {:id => 'number',:label => "New Users",:type  => "number"}]

    start_at = params[:start_at].present? ? params[:start_at].to_time : 2.weeks.ago.midnight
    end_at = params[:end_at].present? ? params[:end_at].to_time : Time.now.utc

    rows = User.chart_users(start_at, end_at)
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
