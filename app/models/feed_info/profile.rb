class FeedInfo::Profile
	include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
                  
  field :category, type: String
	index :feed_info_id
	index :profile_id
  index :profile_category_id	
	belongs_to :feed_info
	belongs_to :profile
        belongs_to :profile_category
end
