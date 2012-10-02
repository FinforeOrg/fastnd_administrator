class UserFeed::FeedInfo < Base::FeedInfo
	#Fake Associations to Pass RSPEC
	attr_accessor :user_feeds, :price_tickers, :user_company_tabs, :company_competitor, :feed_info_profiles
end