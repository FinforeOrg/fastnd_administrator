module GMoney
  # = GFSession
  #
  # Holds the authenicated user's token which is need
  # for each request sent to Google
  #
  class GFSession
    OAUTH_OPTIONS = {  :site => 'https://www.google.com',
                       :request_token_path => '/accounts/OAuthGetRequestToken',
                       :access_token_path => '/accounts/OAuthGetAccessToken',
                       :authorize_path => '/accounts/OAuthAuthorizeToken'
                     }
    
    def self.login(email, password, opts={})
      @email = email
      auth_request = GMoney::AuthenticationRequest.new(email, password)
      @auth_token = auth_request.auth_token(opts)
    end

    def self.login_oauth(options={})
      @consumer_key = options[:consumer_key]
      @consumer_secret = options[:consumer_secret]
      @oauth_token = options[:token]
      @oauth_secret = options[:secret]
      @email = options[:email]
      consumer = OAuth::Consumer.new(@consumer_key,@consumer_secret,OAUTH_OPTIONS)
      @access_token = OAuth::AccessToken.new(consumer, @oauth_token, @oauth_secret)
    end

    def self.consumer_key
      @consumer_key
    end

    def self.consumer_secret
      @consumer_secret
    end

    def self.oauth_token
      @oauth_token
    end

    def self.oauth_secret
      @oauth_secret
    end
    
    def self.auth_token
      @auth_token
    end

    def self.access_token
      @access_token
    end

    def self.email
      @email
    end
    
    def self.logout
      @email = nil
      @auth_token = nil
      @access_token = nil
      @oauth_secret = nil
      @oauth_token = nil
      @consumer_secret = nil
      @consumer_key = nil
    end    
  end
end
