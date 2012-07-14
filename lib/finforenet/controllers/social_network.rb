module Finforenet
  module Controllers 
    module SocialNetwork
      extend ActiveSupport::Concern
      
      included do
      end

			private
			
			  def authorize_url
					if @api
					  session[@cat].merge!({:column_id => params[:feed_account_id]}) if has_column_id?
					  session[@cat].merge!({:rt => '', :rs => '', :category => @api.category, :callback => params[:callback]})
					  
					  unless @api.isFacebook?
							request_token = get_request_token
							session[@cat].merge!({:rt => request_token.token, :rs => request_token.secret})
							auth_url = request_token.authorize_url({:force_login => 'false'})
					  else
						  auth_url = FGraph.oauth_authorize_url(@api.api, @callback_url, :scope=> OauthMedia.fb_permissions)
					  end
					end
					
					return auth_url
			  end
			  
			  def has_column_id?
				  params[:controller] =~ /feed_account/i && params[:feed_account_id].present?
				end
		  
			  def get_request_token
				  opts = @api.isGoogle? ? OauthMedia.google_scopes : {}
			    consumer.get_request_token({:oauth_callback => @callback_url}, opts)
			  end
		
			  def consumer
			    OauthMedia.consumer(@api)
			  end
			  
			  def prepare_callback
				  @api = FeedApi.auth_by(params[:provider])
				  @cat = random_characters if @cat.blank?
				  session[@cat] ||= {} if session[@cat].blank?
				  params.merge!({:host => request.host, :security => @cat})
				  @callback_url = OauthMedia.oauth_callback(current_user, params)
				end
			  
			  def get_network_access
			  	@api = FeedApi.auth_by(@stored_data[:category]) unless @api
			  	params.merge!({:rt => session[@cat][:rt], :rs => session[@cat][:rs]})
			  	return OauthMedia.access_token(@api,params)
			  end

			  def get_failed_message
			    "Sorry - your request does not meet requirements"
			  end
      
    end
  end
end
