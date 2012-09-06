module Finforenet
  module Models 
    module SharedQuery
      extend ActiveSupport::Concern
      
      included do
	      include InstancesMethods
      end

      module InstancesMethods
		
		    def updated_position
			    _record = self.class.all.desc(:position).first
			    _record ? (_record.position.to_i + 1) : 0
				end
	  
      end
      
      module ClassMethods
		    def rss_query(options = {})
		    	options["$and"] = [{:address=> REGEX_HTTP}, {:address=>{"$not"=> REGEX_MULTIMEDIA}}]
		    	options[:category] = Regexp.new('rss',Regexp::IGNORECASE)
		    	return options
		    end
		    
		    def company_query(options={})
		    	single_ticker = {"$and" => [{:category => REGEX_COMPANY}, {:category => {"$not" => /chart/i}}, {:address => /^\W/i}, 
{:address => {"$not" => /\s+/}}, {:address=> {"$not" => REGEX_HTTP}} ] }
		    	#options.merge!({"$or" => [{:category => REGEX_COMPANY}, single_ticker ]})
                        options.merge!(single_ticker)
		    	#options.merge!({:address=> {"$not" => REGEX_HTTP}, :category => {"$not" => /chart/i} })
		    	return options
		    end
		    
		    def twitter_query(options = {})
		    	options.merge!({:category => /twitter/i, :address => {"$not" => REGEX_HTTP}})
		    	return options
		    end
		    
		    def all_companies_query(options={})
		    	return company_query(options)
		    end
		    
		    def populated_query(options = {})
		    	options[:is_populate] = true
		    	return options
		    end
		    
		    def profiles_query(user, options = {})
		    	profile_ids = user.user_profiles.map(&:profile_id)
		    	feed_info_ids = FeedInfo::Profile.where(:profile_id.in => profile_ids).map(&:feed_info_id)
		    	options[:_id] = {"$in" => feed_info_ids} unless feed_info_ids.size < 1
		    	return options
		    end

                   def sectors_query(profile_ids, options = {})
                        feed_info_ids = FeedInfo::Profile.where(:profile_id.in => profile_ids).map(&:feed_info_id)
                        options[:_id] = {"$in" => feed_info_ids} unless feed_info_ids.size < 1
                        return options
                    end
		    
		    def podcast_query(options={})
		    	options.merge!({:category => /podcast/i, 
			    	             "$and" => [{:address => REGEX_HTTP}, 
				    	                      {:address => {"$not" => /youtube/i}}
				    	                     ]
				    	          })
		    	return options
		    end

                    def broadcast_query(options={})
                        options.merge!({:category => /video|youtube|broadcast/i,
                                             "$and" => [{:address => REGEX_HTTP},
                                                              {:address => /youtube/i}
                                                             ]
                                                  })
                        return options
                    end
		    
		    def chart_query(options={})
		    	options.merge!({:category => /chart|price/i, :title => /\w|\W/i})
		    end  
                    def price_query(options={})
                      chart_query(options)
                    end
      end
      
    end
  end
end
