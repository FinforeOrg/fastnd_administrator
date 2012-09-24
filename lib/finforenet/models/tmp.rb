User.all.each do |user|
  user._profile_ids = user.user_profiles.map(&:profile_id)
  user.save
end

FeedInfo.all.each do |info|
  info._profile_ids = info.feed_info_profiles.map(&:profile_id)
  info.save
end

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
  if tmp_match > total_match
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
results = matches.slice(-5,5)
y = Time.now
results.map{|r| [{score: r[:score], tota: r[:total_match]}]}
y-x
