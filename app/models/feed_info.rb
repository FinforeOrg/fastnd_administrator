class FeedInfo < Base::FeedInfo  
  field :is_populate, :type => Boolean, :default => false
  field :position,    :type => Integer
  index :is_populate
  index :position

  validates :title,    :presence => true
  #Associations
  has_many :user_feeds,          :dependent => :destroy
  has_many :price_tickers,       :dependent => :destroy, :autosave => true
  has_many :user_company_tabs,   :dependent => :destroy
  has_one  :company_competitor,  :dependent => :destroy
  has_many :feed_info_profiles,  :dependent => :destroy, :class_name => "FeedInfo::Profile"
  accepts_nested_attributes_for :price_tickers, :reject_if => proc{|obj| obj[:ticker].blank? }
  attr_accessor :profile_ids
  before_save :before_saving

  def self.filter_feeds_data(conditions, _limit, _page)
    result = self
    result = result.includes(:feed_info_profiles) if conditions[:_id]
    result = result.where(conditions)
    if conditions[:category] && conditions[:category] =~ /price|chart/i
      result = result.asc(:position).asc(:title)
    else
      result = result.asc(:title)
    end
    return result
  end

  def self.all_with_competitor(conditions)
    results = self.includes(:company_competitor).where(conditions)
    results = results.sort_by{|r| r.profiles.count}.reverse if conditions[:profile_ids]
    return results
  end

  def self.all_sort_title(conditions)
    result = self.includes(:price_tickers).where(conditions)
    if conditions[:category] && conditions[:category] =~ /price|chart/i
      result = result.order_by([:position, :asc], [:title, :asc])
    else
      result = result.asc(:title)
    end
    return result
  end

   def self.CsvHeader
    categories = ProfileCategory.all.map(&:title)
    ["Id", "Title", "Category", "Address"] + categories
  end

  def csv_row
    profile_ids = self.feed_info_profiles.map(&:profile_id)
    row = [self.id.to_s, self.title, self.category, self.address]
    ProfileCategory.all.each do |pc|
      row << pc.profiles.where(:_id.in => profile_ids).map(&:title).join(",")
    end
    row
  end

  def profiles
    Profile.find(self.feed_info_profiles.map(&:profile_id))
  end

  def validate_rss
    return true
    #return true unless self.isRss?
    #result = HTTParty.get(self.address)
    #result.headers['content-type'] =~ /xml|rss|atom/i || result.body =~ /(\s*[<][\?]xml[^>?]+\?>\s)/i
    #rescue
    #  return false
  end

  def email_invalid_rss
    UserMailer.invalid_rss(self).deliver
  end

  #TODO : Tear down this method if not used yet
  def self.search_populates(options,is_company_tab=false)
    feed_infos = self.where(options)
    if is_company_tab
      feed_infos = feed_infos.select{|info| info if !info.company_competitor.blank? }
    end
    feed_infos = feed_infos.sort{|fi| fi.profile_ids.size}.sort{|x,y| y.profile_ids.size <=> x.profile_ids.size}
 
    if feed_infos.size < 4 && !is_company_tab
      current_ids = feed_infos.map(&:id)
      options.merge!({"$nin" => current_ids})
      more_results = self.where(options).limit(4-feed_infos.size)
      feed_infos += more_results
    else
      feed_infos = feed_infos.slice(0,4)
    end

    return feed_infos
  end

  def self.with_populated_prices
    self.where(:title => /(DJ Indus)|(Equity Indi)/i)
  end
  
  def selected_profiles
    self.feed_info_profiles.map{|up| up.profile_id}
  end

  def isSuggestion?
    self.category =~ /(tweet|twitter|suggest)/i
  end

  def isRss?
    self.category =~ /(rss)/i
  end

  def isPodcast?
   self.category =~ /(podcast|video|audio)/i
  end

  def isChart?
    self.category =~ /(price|chart)/i
  end

  def isCompany?
    self.category =~ /(company|index|currency)/i
  end

  def isKeyword?
    self.category =~ /(keyword)/i
  end

  def before_saving
    if self.valid? && self.profile_ids.present? && self.profile_ids.count > 0
      self.feed_info_profiles.delete_all 
      self.profile_ids.map{|pi| FeedInfo::Profile.create({:feed_info_id => self.id, :profile_id => pi })}
    end
    if self.valid? && self.position.blank?
      lastest = self.class.where(:category => /#{self.category}/i).desc(:position).first
      self.position = lastest ? (lastest.position.to_i + 1) : 1
    end
    if self.isRss? && !self.validate_rss
      self.errors.add(:address, "is not valid or not rss")
    end
  end

end
