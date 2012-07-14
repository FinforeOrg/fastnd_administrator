class User::Profile
	include Mongoid::Document
	index :user_id
	index :profile_id
	
	belongs_to :user
	belongs_to :profile
	
end