class FeedInfo::Profile
	include Mongoid::Document
        field :category, type: String
	index :feed_info_id
	index :profile_id
        index :profile_category_id	
	belongs_to :feed_info
	belongs_to :profile
        belongs_to :profile_category
end
