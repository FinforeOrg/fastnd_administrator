module OauthMedia
	
	def self.consumer(token)
		OAuth::Consumer.new(token.api, token.secret, network_options(token.category))
	end
	
	def self.oauth_access_token(token, request_token="", request_secret="",verifier="")
		OAuth::RequestToken.new(consumer(token), request_token, request_secret).get_access_token(:oauth_verifier => verifier)
	end
	
	def self.access_token(api,opts={})
		unless api.isFacebook?
			access_token = self.oauth_access_token(api,opts[:rt],opts[:rs], opts[:oauth_verifier])
		else
			access_token = FGraph.oauth_access_token(@api.api, @api.secret, fb_access_opts(opts))
			access_token = OpenStruct.new access_token
		end
	end
	
	def self.fb_access_opts(opts={})
		{:code=>opts[:code], :redirect_uri => @callback_url}
	end
	
	def self.oauth_callback(user, opts={})
		if opts[:controller] =~ /feed_account/i
			single_token_param = "finfore_token=#{user.single_access_token}"
			auth_token_param = "finfore_token=#{opts[:finfore_token]||opts[:auth_token]}"
			url_query = user ? single_token_param : auth_token_param
			callback_url = "http://#{opts[:host]}/feed_accounts/column_callback?#{url_query}&cat=#{opts[:security]}"
			callback_url = callback_url + "&format=json" if opts[:callback].blank?
		else
			callback_url = "http://#{opts[:host]}/auth/#{opts[:provider]}/callback?cat=#{opts[:security]}"
		end
		return callback_url
	end
	
	def self.network_options(category)
		send("#{category}_options")
	end
	
	def self.google_options
		return { :site               => 'https://www.google.com',
						 :request_token_path => '/accounts/OAuthGetRequestToken',
						 :access_token_path  => '/accounts/OAuthGetAccessToken',
						 :authorize_path     => '/accounts/OAuthAuthorizeToken'
					 }
	end

	def self.twitter_options
		return {:site => 'https://api.twitter.com', 
			      :authorize_path => '/oauth/authorize' }
	end

	def self.linkedin_options
		return { :site               => 'https://api.linkedin.com',
						 :request_token_path => '/uas/oauth/requestToken',
						 :access_token_path  => '/uas/oauth/accessToken',
						 :authorize_path     => '/uas/oauth/authorize',
						 :scheme             => :header
					 }
	end

	def self.google_scopes
		return {:scope => ["http://www.google.com/m8/feeds/", 
											 "http://finance.google.com/finance/feeds/", 
											 "https://mail.google.com/", 
											 "http://www.google.com/reader/api", 
											 "https://www.google.com/calendar/feeds/", 
											 "http://gdata.youtube.com"].join(" ")}
	end
	
	def self.fb_permissions
		perms  = "read_friendlists,read_mailbox,read_stream,xmpp_login,manage_notifications" 
		perms += "," + "offline_access,publish_stream,email,user_work_history"
		perms += "," + "user_status,user_hometown,user_education_history"
		return perms
	end

	def self.linkedin_profile(access_token)
		result = access_token.get('/v1/people/~:(id,first-name,last-name)').body
		person = Nokogiri::XML::Document.parse(result).xpath('person')
		return {'username' => person.xpath('id').text, 
					  'provider' => "linkedin", 
						'name'     => "#{person.xpath('first-name').text} #{person.xpath('last-name').text}"}
	end
	
	def self.google_profile(access_token)
		result = access_token.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=1&alt=json").body
		person = Yajl::Parser.parse(result)
		email = person['feed']['id']['$t']
		name = person['feed']['author'].first['name']['$t']
		name = email if name.strip =~ /unknown/i
		return {'username' => email, 'provider' => "google", 'name' => name }
	end
	
	def self.twitter_profile(access_token)
		result = access_token.get('/1/account/verify_credentials.json').body
		person = Yajl::Parser.parse(result)
		return {'username' => person['screen_name'],'name' => person['name'], 'provider' => "twitter"}
	end
	
	def self.facebook_profile(access_token)
		person = FGraph.me(:access_token => access_token.access_token)
		facebook_email = person.parsed_response['email']
		facebook_email = person.parsed_response['name'].gsub(/\W/i,"_") + "@" + "facebook.com" if facebook_email.blank?
		person_hash = {'username'=>facebook_email, 'name' => person.parsed_response['name'], 'provider' => "facebook"}
	end

	def self.profile_network(access_token, category)
		send("#{category}_profile", access_token)
	end
	
end