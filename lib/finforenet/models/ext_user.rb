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
        current_profile_ids = self.user_profiles.map(&:profile_id)
        countries, sectors, professions = [], [], []
        current_profile_ids.each do |profile_id|
          next if profile_id.blank?
          profile = Profile.find(profile_id)
          if profile
            if profile.profile_category.title =~ /geo/i
              countries.push(profile_id)
            elsif profile.profile_category.title =~ /ind/i
              sectors.push(profile_id)
            elsif profile.profile_category.title =~ /pro/i
              professions.push(profile_id)
            end
          end
        end

         populate_company_tabs(countries, sectors, professions)
         populate_prices(countries, sectors, professions)
      end

      def populate_prices(countries, sectors, professions)
        results = populated_resources(countries, sectors, professions, "price")
        results.each do |result|
          self.feed_accounts.create({name: result.title, 
                                     category: "Price",
                                      user_feeds_attributes: [
                                        {title: result.title, feed_info_id: result.id}
                                      ]
                                    })
        end
      end

      def populate_company_tabs(countries, sectors, professions)
        results = populated_resources(countries, sectors, professions, "company")
        results.each do |result|
          self.user_company_tabs.find_or_create_by({follower: 100, is_aggregate: false, feed_info_id: result.id})
        end
      end

      def populated_resources(countries, sectors, professions, category)
        populations = SourcePopulation.where({category: "company", 
                                              :country_ids.in => countries, 
                                              :sector_ids.in => sectors, 
                                              :profession_ids.in => professions
                                            })
        source_ids = populations.map{|population| population.sources}.flatten.compact.uniq
        FeedInfo.where({:_id.in => source_ids}).desc(:votes).limit(5)
      end

    end
  end
end