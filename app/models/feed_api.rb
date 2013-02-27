class FeedApi
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  #Fields
  field :api,      :type => String
  field :secret,   :type => String
  field :category, :type => String
  
  index :category
  
  cache
  
  def self.auth_by(category)
	category = category.gsub(/gmail|portfolio/i,"google")
	self.where(:category => /#{category}/i).first
  end

  def isFacebook?
    self.category =~ /(facebook)/i
  end
  
  def isLinkedin?
    self.category =~ /linkedin/i
  end
  
  def isTwitter?
    self.category =~ /twitter|tweet/i
  end
  
  def isGoogle?
    self.category =~ /google|gmail|portfolio/i
  end

end
