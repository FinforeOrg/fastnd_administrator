module Finforenet
  module Models
    module CoCode
      def self.company_twitter(path="")
      	infos = FeedInfo.create({:address => /(company|index|currency)/i})
      	infos.map{|info| info.destroy}
      	path = "#{Rails.root}/company.csv" if path.blank?
        csv_file = File.new(path).read
        csv_data = CSV.parse(csv_file)
        header = Hash[csv_data.shift.each_with_index.map{| val,key | [val.downcase.gsub(" ","_"), key]}].to_options
        
        csv_data.each do |row|
        	feed_info = FeedInfo.where(:address => row[header[:twitter]])
        	unless feed_info
            profile_ids = ["4ed12d737b3fc6412e0001bb","4ed12d737b3fc6412e0001bc","4ed12d737b3fc6412e0001bd","4ed12d737b3fc6412e0001be"]
            geo_profile = Profile.where({:title => /#{row[header[:geographic]}/i }).first
            profile_ids << geo_profile.id if geo_profile
            industry_profile = Profile.where({:title => /#{row[header[:industry]}/i }).first
            profile_ids << industry_profile.id if industry_profile
        		feed_info = FeedInfo.create({:address  => row[header[:twitter], 
        			                           :title    => row[header[:title]],
        			                           :category => "Company",
        			                           :profile_ids => profile_ids
        			                          })
        		if feed_info
        			company = CompanyCompetitor.create({:keyword                => row[header[:competitor_keyword]],
        				                                  :competitor_ticker      => row[header[:competitor_ticker]],
        				                                  :company_keyword        => row[header[:keyword]],
																								  :broadcast_keyword      => row[header[:broadcast_keyword]],
																								  :finance_keyword        => row[header[:finance_keyword]],
																								  :bing_keyword           => row[header[:bing_keyword]],
																								  :blog_keyword           => row[header[:blog_keyword]],
																								  :company_ticker         => row[header[:ticker]],
																								  :feed_info              => feed_info.id
        				                                 })
        		end
        	end
        end
      end

    end
  end
end
  #{:title=>0, 
  # :geographic=>1, 
  # :industry=>2, 
  # :profession=>3, 
  # :ticker=>4, 
  # :keyword=>5, 
  # :competitor_ticker=>6, 
  # :competitor_keyword=>7, 
  # :broadcast_keyword=>8, 
  # :finance_keyword=>9, 
  # :bing_keyword=>10, 
  # :blog_keyword=>11,
  # :twitter => 12}