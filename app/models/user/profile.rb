class User::Profile
	include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
                  
	index :user_id
	index :profile_id
	
	belongs_to :user
	belongs_to :profile
	
end