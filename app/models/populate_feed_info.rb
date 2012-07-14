class PopulateFeedInfo
  include Mongoid::Document
  
  field :is_company_tab, :type => Boolean
  
  belongs_to :feed_info, :index => true
  has_and_belongs_to_many :profiles, :index => true
  
  def self.find_by_tags(user, category)
    self.includes(:feed_info).where(:feed_info => {:category => /#{category}/i }).order({:feed_info => :title})
  end

end
