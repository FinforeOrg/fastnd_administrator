require 'csv'
module Finforenet
  module Models
    module CoCode
      def self.company_twitter(path="")
        infos = FeedInfo.where({:category => /(company|index|currency)/i})
        infos.map{|info| info.destroy}
        path = "#{Rails.root}/company.csv" if path.blank?
        csv_file = File.new(path).read
        csv_data = CSV.parse(csv_file)
        header = Hash[csv_data.shift.each_with_index.map{| val,key | [val.downcase.gsub(" ","_"), key]}].to_options
        
        csv_data.each do |row|
        	feed_info = FeedInfo.where(:address => row[header[:twitter]]).first
        	unless feed_info
            profile_ids = ["4ed12d737b3fc6412e0001bb","4ed12d737b3fc6412e0001bc","4ed12d737b3fc6412e0001bd","4ed12d737b3fc6412e0001be"]
            geo_profile = Profile.where({:title => /#{row[header[:geographic]]}/i }).first
            profile_ids << geo_profile.id if geo_profile
            industry_profile = Profile.where({:title => /#{row[header[:industry]]}/i }).first
            profile_ids << industry_profile.id if industry_profile
        		feed_info = FeedInfo.create({:address  => row[header[:twitter]], 
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

       def self.import_price(path="")
         path = "#{Rails.root}/price_columns.csv" if path.blank?
         csv_file = File.new(path).read
         csv_data = CSV.parse(csv_file)
         csv_data.shift if csv_data.first[0] =~ /title/i
         header = {:title => 0, :geography => 1, :industry => 2, :profession => 3, :tickers => 4}
         FeedInfo.where(category: /Chart|Price/i).destroy_all
         PriceTicker.all.destroy_all
         csv_data.each do |row|
           geo_ids = Profile.any_in(:title => row[header[:geography]].split(/\,\s/)).map(&:id)
           ind_ids = Profile.any_in(:title => row[header[:industry]].split(/\,\s/)).map(&:id)
           pro_ids = Profile.any_in(:title => row[header[:profession]].split(/\,\s/)).map(&:id)
           tickers = row[header[:tickers]].split(/\s/).map{|ticker| {:ticker => ticker}}
           profile_ids = pro_ids + geo_ids + ind_ids
           FeedInfo.create({:address => row[header[:title]], 
                            :title => row[header[:title]], 
                            :category => "Price", 
                            :profile_ids => profile_ids, 
                            :price_tickers_attributes => tickers})
         end
       end

       def self.update_feed_infos(path)
         header = {:id => 0, :title => 1, :category => 2, :address => 3, :industry => 4, :geography => 5, :profession => 6}
         csv_data = CSV.read(path, :encoding => 'windows-1251:utf-8')
         csv_data.shift if csv_data.first[0] =~ /id/i
         total_update = 0
         total_create = 0
         csv_data.each do |row|
           #next if row[header[:category]] =~ /price|chart|company/i
           profile_titles = row[header[:industry]].split(",") + row[header[:geography]].split(",") + row[header[:profession]].split(",")
           profile_titles = profile_titles.map{|x| x.gsub(/^\s|\s$/,"")}.compact.uniq
           profile_ids = Profile.any_in({:title => profile_titles}).map(&:id)
           opts = {:address => row[header[:address]], :title => row[header[:title]], :category => row[header[:category]], :profile_ids => profile_ids }
           if row[header[:id]].present?
             info = FeedInfo.find(row[header[:id]])
             unless info
               info = FeedInfo.where({:address => row[header[:address]], :category => /#{row[header[:category]]}/i }).first
             end
             if info
               info.update_attributes(opts) 
               total_update += 1
             end
           end
           unless info
             total_create += 1
             info = FeedInfo.create(opts)
           end
         end
         return {:total_update => total_update, :total_create => total_create}
       end
       
       def self.update_company(path="")
         header = {:title => 0, :twitter => 1, :ticker => 2, :competitor_ticker => 3, :competitor_keyword => 4}
         path = "#{Rails.root}/fastnd_extended.csv" if path.blank?
         csv_file = File.new(path).read
         csv_data = CSV.parse(csv_file)
         csv_data.shift if csv_data.first[0] =~ /title/i
         counter = {:record => 0, :new => 0, :update => 0}
         csv_data.each do |row|
           company = CompanyCompetitor.where(:finance_keyword => row[header[:ticker]]).first
           info_obj = {:address  => row[header[:twitter]], 
                       :title    => row[header[:title]], 
                       :category => "Company"
                      }
           company_obj = {:keyword           => row[header[:competitor_keyword]].to_s.split(/\s/).join(","),
                          :competitor_ticker => row[header[:competitor_ticker]].to_s.split(/\s/).join(","),
                          :company_keyword   => "#{row[header[:ticker]]},\"#{row[header[:title]]}\"",
                          :broadcast_keyword => row[header[:title]],
                          :finance_keyword   => row[header[:ticker]],
                          :bing_keyword      => "#{row[header[:ticker]]},#{row[header[:title]]}",
                          :blog_keyword      => "#{row[header[:ticker]]},#{row[header[:title]]}",
                          :company_ticker    => row[header[:ticker]]
                          }
           if company
             counter[:update] += 1
             info = company.feed_info
             info.update_attributes(info_obj)
             company.update_attributes(company_obj)
           else
             counter[:new] += 1
             #info = FeedInfo.create(info_obj)
             #CompanyCompetitor.create(company_obj.merge!(:feed_info_id => info.id)) if info.valid?
           end
           counter[:record] += 1
         end
         return counter
       end

       def self.async_populate_podcast
         header = {:id => 0, :title => 1, :category => 2, :address => 3, :autopopulate => 4, :industry => 5, :geography => 6, :profession => 7}
         path = "#{Rails.root}/autopopulate_podcast.csv" if path.blank?
         csv_file = File.new(path).read
         csv_data = CSV.parse(csv_file)
         counter = {:record => 0, :found => 0, :not_found => 0, :not_found_data => []}
         csv_data.shift if csv_data.first[0] =~ /ID/i
         csv_data.each do |row|
           counter[:record] += 1
           next unless row[header[:id]]

           feed_info = FeedInfo.find(row[header[:id]])
           next unless feed_info

           countries, sectors, professions = [], [], []
           feed_info.selected_profiles.each do |profile_id|
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

           country_profiles    = row[header[:geography].blank? ? countries : Profile.any_in(title: self.sanitize_array(row[header[:geography]].split(","))).map(&:id)
           sector_profiles     = row[header[:industry].blank? ? sectors : Profile.any_in(title: self.sanitize_array(row[header[:industry]].split(","))).map(&:id)
           profession_profiles = row[header[:profession].blank? ? professions : Profile.any_in(title: self.sanitize_array(row[header[:profession]].split(","))).map(&:id)
           all_profiles = country_profiles + sector_profiles + profession_profiles

           feed_info.update_attributes({title: row[header[:title]],
                                        address: row[header[:address]],
                                        profile_ids: all_profiles
                                      })
           
           SourcePopulation.create({profession_ids: profession_profiles,
                                    country_ids: country_profiles, 
                                    sector_ids: sector_profiles,
                                    profile_ids: all_profiles,
                                    category: "podcast",
                                    sources: [feed_info.id]
                                  }) if row[header[:autopopulate]].to_s =~ /yes/i
           counter[:found] += 1
         end
       end

       def self.async_populate_price
         header = {:id => 0, :title => 1, :category => 2, :address => 3, :industry => 4, :geography => 5, :profession => 6}
         path = "#{Rails.root}/autopopulate_price.csv" if path.blank?
         csv_file = File.new(path).read
         csv_data = CSV.parse(csv_file)
         counter = {:record => 0, :found => 0, :not_found => 0, :not_found_data => []}
         csv_data.shift if csv_data.first[0] =~ /ID/i
         csv_data.each do |row|
           counter[:record] += 1
           next unless row[header[:id]]

           country_profiles    = Profile.any_in(title: self.sanitize_array(row[header[:geography]].split(","))).map(&:id)
           sector_profiles     = Profile.any_in(title: self.sanitize_array(row[header[:industry]].split(","))).map(&:id)
           profession_profiles = Profile.any_in(title: self.sanitize_array(row[header[:profession]].split(","))).map(&:id)
           all_profiles = country_profiles + sector_profiles + profession_profiles

           feed_info = FeedInfo.find(row[header[:id]])
           next unless feed_info

           feed_info.update_attributes({title: row[header[:title]],
                                        address: row[header[:address]],
                                        profile_ids: all_profiles
                                      })
           
           SourcePopulation.create({profession_ids: profession_profiles,
                                    country_ids: country_profiles, 
                                    sector_ids: sector_profiles,
                                    profile_ids: all_profiles,
                                    category: "price",
                                    sources: [feed_info.id]
                                  })
           counter[:found] += 1
         end
       end
       
       def self.async_populate_company
         header = {:country => 0, :sector => 1, :profession => 2, :companies => 3}
         path = "#{Rails.root}/autopopulate_company.csv" if path.blank?
         csv_file = File.new(path).read
         csv_data = CSV.parse(csv_file)
         counter = {:record => 0, :found => 0, :not_found => 0, :not_found_data => []}
         csv_data.shift if csv_data.first[0] =~ /country|profession/i
         csv_data.each do |row|
           companies = row[header[:companies]]
           next if companies.blank?
           country_profiles    = Profile.any_in(title: self.sanitize_array(row[header[:country]].split(","))).map(&:id)
           sector_profiles     = Profile.any_in(title: self.sanitize_array(row[header[:sector]].split(","))).map(&:id)
           profession_profiles = Profile.any_in(title: self.sanitize_array(row[header[:profession]].split(","))).map(&:id)
           all_profiles = country_profiles + sector_profiles + profession_profiles
           sources   = []
           companies = (companies =~ /\,/) ? companies.split(/\,/) : companies.split(/\s/)
           companies = self.sanitize_array(companies)
           companies.each do |company|
             company_ticker = CompanyCompetitor.where({company_ticker: company}).first
             if company_ticker
               feed_info = company_ticker.feed_info
               sources.push(feed_info.id)
             end
           end
           SourcePopulation.create({profession_ids: profession_profiles,
                                    country_ids: country_profiles, 
                                    sector_ids: sector_profiles,
                                    profile_ids: all_profiles,
                                    category: "company",
                                    sources: sources
                                  })
         end
       end
      
       def self.sync_populate_company(path="")
          header = {:country => 0, :sector => 1, :profession => 2, :companies => 3}
          path = "#{Rails.root}/autopopulate_company.csv" if path.blank?
          csv_file = File.new(path).read
          csv_data = CSV.parse(csv_file)
          counter = {:record => 0, :found => 0, :not_found => 0, :not_found_data => []}
          csv_data.shift if csv_data.first[0] =~ /country|profession/i
          csv_data.each do |row|
            companies = row[header[:companies]]
            next if companies.blank?
            companies = (companies =~ /\,/) ? companies.split(/\,/) : companies.split(/\s/)
            # sanitize array element from unnecessary white spaces
            companies = self.sanitize_array(companies)
            profile_titles = row[header[:country]].split(",") + row[header[:sector]].split(",") + row[header[:profession]].split(",")
            profile_titles = profile_titles.map{|profile| profile.gsub(/^\s|\s$/,"")}.compact.uniq
            profiles = Profile.any_in(:title => profile_titles)
            companies.each do |company|
              company_ticker = CompanyCompetitor.where({company_ticker: company}).first
              if company_ticker && feed_info = company_ticker.feed_info
                profiles.each do |profile|
                  FeedInfo::Profile.find_or_create_by({profile_id: profile.id, feed_info_id: feed_info.id})
                end
                unless feed_info.is_populate
                  feed_info.update_attribute(:is_populate, true) 
                  counter[:found] += 1
                end
              elsif !counter[:not_found_data].include?(company)
                counter[:not_found] += 1
                counter[:not_found_data].push(company)
              end
              counter[:record] += 1
            end
          end
          #{:record=>898, :found=>540, :not_found=>5, :not_found_data=>["", "NSE:STER", "LON:BLY", "TYO:9715", "TPE:4104"]}
          return counter
       end

       private

       def self.sanitize_array(arr)
         arr.map{|profile| profile.gsub(/^\s|\s$/,"").gsub(/\s{2,}/," ")}
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
