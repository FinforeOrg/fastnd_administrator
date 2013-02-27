class AccessToken
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :category, :type => String
  field :token,    :type => String
  field :secret,   :type => String
  field :username, :type => String
  
  index :category
  index :username
  
  belongs_to :user
end
