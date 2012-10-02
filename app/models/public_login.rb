class PublicLogin
	include Mongoid::Document
	include Mongoid::Timestamps
	field :profile_ids
	field :user_id
end