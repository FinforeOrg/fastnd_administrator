class FeedInfo::Profile
	include Mongoid::Document
	index :feed_info_id
	index :profile_id
	
	belongs_to :feed_info
	belongs_to :profile
end