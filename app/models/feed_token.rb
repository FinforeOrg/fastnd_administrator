class FeedToken
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true

  field :token,          :type => String
  field :secret,         :type => String
  field :token_preauth,  :type => String
  field :secret_preauth, :type => String
  field :url_oauth,      :type => String
  field :username,       :type => String
  
  index :username
  index :token
  index :secret
  index :token_preauth
  index :secret_preauth

  embedded_in :feed_account

end
