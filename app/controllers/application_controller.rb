class ApplicationController < ActionController::Base
  include ActionView::Helpers::TextHelper
  
  include Finforenet::Controllers::Filterable
  include Finforenet::Controllers::Responder

  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user

  before_filter :require_user
  before_filter :version
  #rescue_from ActionController::RoutingError, :with => :render_404

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = AdminCoreSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    redirect_to :controller => :user_sessions,:action=>:new if !current_user
  end

  def require_no_user
    redirect_to :controller=>:user_sessions,:action=>:new if !current_user
  end

  def version
    @version = '0.1.0'
    @html_entity = HTMLEntities.new
    dashboard_selections
  end

  def dashboard_selections
    @dashboard_selected = false
    @focuses_selected = false
    @users_selected = false
    @suggestions_selected = false
    @company_tabs_selected = false
    @noticeboards_selected = false
    @settings_selected = false
    @prices_selected = false
  end

  def render_404(exception = nil)
    if exception
        logger.debug "Rendering 404: #{exception.message}"
    end

    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end  
  
  def local_request?
    false
  end

  def render_400()
    log_exception(exception)
    #render :file => '/errors/400', :status => 400
  end

  def render_422(exception)
    log_exception(exception)
    #render :file => '/errors/400', :status => 400
  end

  def render_500(exception)
    log_exception(exception)
    #render :file => '/errors/400', :status => 400
  end

  def generate_password
    return SecureRandom.hex(4)
    #return (1..8).map{ (0..?z).map(&:chr).grep(/[a-z\d]/i)[rand(62)]}.join
  end

  def prepare_followers
   @followers = [["Any no. of followers",0],["At least 100 followers",100],["At least 1000 followers",1000]]
  end
  
  def build_file(content_type, filename)
      #this is required if you want this to work with IE
      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain"
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = "0"
      else
        headers["Content-Type"] ||= content_type
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
        headers["Content-Transfer-Encoding"] = "binary"
      end
  end


end
