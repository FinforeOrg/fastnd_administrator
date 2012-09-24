User.all.each do |user|
  user._profile_ids = user.user_profiles.map(&:profile_id)
  user.save
end

FeedInfo.all.each do |info|
  info._profile_ids = info.feed_info_profiles.map(&:profile_id)
  info.save
end

#SAMPLE synchronous POPULATION
x = Time.now
user = User.where(email_work: /yacobus/i).first
options = FeedInfo.populated_query(FeedInfo.all_companies_query)
options.merge!({:_profile_ids.in => user._profile_ids})
companies = FeedInfo.where(options).desc(:votes)
total_match = 0
matches = []
user_profiles = user.user_profiles.map(&:profile_id)
companies.each do |company|
  next if company.company_competitor.blank?
  company_profiles = company.feed_info_profiles.map(&:profile_id)
  diff_match = user_profiles - company_profiles
  tmp_match = user_profiles.count - diff_match.count
  if tmp_match > 0
    if matches.count < 6
      total_match = tmp_match
      matches.push({company: company, score: company.votes, total_match: tmp_match}) 
    else
      sorted = matches.sort{|x,y| [y[:total_match], y[:score]] <=> [x[:total_match], x[:score]]}
      element = sorted.last
      next if element[:total_match] > tmp_match
      if company.votes > element[:score]
        sorted.pop
        sorted.push({company: company, score: company.votes, total_match: tmp_match})
        matches = sorted
        total_match = tmp_match
      end
    end
  end
end
results = matches.slice(0,5)
y = Time.now
results.map{|r| [{score: r[:score], tota: r[:total_match]}]}
y-x

#SAMPLE asynchronous POPULATION
x = Time.now
user = User.where(email_work: /yacobus/i).first
user_profiles = user.user_profiles.map(&:profile_id)
countries = []
sectors = []
professions = []
user_profiles.each do |user_profile|
  profile = Profile.find(user_profile)
  if profile
    if profile.profile_category.title =~ /geo/i
      countries.push(user_profile)
    elsif profile.profile_category.title =~ /ind/i
      sectors.push(user_profile)
    elsif profile.profile_category.title =~ /pro/i
      professions.push(user_profile)
    end
  end
end
populations = SourcePopulation.where({category: "company", :country_ids.in => countries, :sector_ids.in => sectors, :profession_ids.in => professions})
source_ids = populations.map{|population| population.sources}.flatten.compact.uniq
results = FeedInfo.where({:_id.in => source_ids}).desc(:votes).limit(5)
y = Time.now
y-x





