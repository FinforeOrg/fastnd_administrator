# Module Extention for user_feed.rb
# Additional Modules/Gems: mongoid_followable
# The extention includes:
#   * Authorize user to have ability to follow or followed
#   * Generate autopopulate from feed_info
module Finforenet
  module Models
    module ExtUser
      extend ActiveSupport::Concern
      
      included do
        include Finforenet::Models::Authenticable
        include Finforenet::Models::SharedQuery
        include Finforenet::Models::Jsonable
        include Mongoid::Followable
        include Mongoid::Follower

        field :_profile_ids, type: Array
      end

      def create_autopopulate
        # ON HOLD
        # ['rss', 'podcast', 'chart'].each do |column|
        #    options = FeedInfo.send("#{column}_query")
        #    options = FeedInfo.populated_query(options).merge!(profiles_query(self))   
           
        #    new_column = FeedAccount.new(options) unless column.match(/chart/i)
        #    feed_infos = FeedInfo.search_populates(options) 
        #    feed_infos = FeedInfo.with_populated_prices if column == 'chart' && @feed_infos.size < 1
          
        #    feed_infos.each do |feed_info|
        #      new_column = FeedAccount.new(options) if column == 'chart'
        #      new_column.user_feeds << UserFeed.new({:feed_info_id => feed_info.id, :title => feed_info.title, :category_type => column})
        #    end
           
        #    self.feed_accounts << new_column
        #    UserMailer.missing_suggestions(self.category).deliver if feed_infos.size < 1
        #  end
         
        #  self.save
      
         #create populate for company tabs
         populate_company_tabs
      end

      def populate_company_tabs
        options = FeedInfo.populated_query(FeedInfo.all_companies_query)
        companies = FeedInfo.where(options).desc(:votes)
        total_match = 0
        matches = []
        user_profiles = self.user_profiles.map(&:profile_id)
        companies.each do |company|
          next if company.company_competitor.blank?
          company_profiles = company.feed_info_profiles.map(&:profile_id)
          diff_match = user_profiles - company_profiles
          tmp_match = user_profiles.count - diff_match
          matches.push(company) if tmp_match > total_match
        end
         
        
        # tab_infos = FeedInfo.search_populates(options,true)
      
        #  tab_infos.each do |company_tab|
        #     self.user_company_tabs << UserCompanyTab.new({:follower => 100, :is_aggregate => false, :feed_info_id => company_tab.id})
        #  end
         
        #  self.save
      end

    end
  end
end