# FeedAccount contains information about instance column
# Column's type (category) would be: 
#   * twitter 
#     - column for user twitter account
#     - its creation needs oauth verification first
#     - the oauth token is stored in feed_token model
#   * company
#     - column for following business twitter accounts
#     - not need authentication for its creation
#     - user could not follow custom business twitter
#   * portfolio
#     - column which contains potfolio finance information
#     - its creation need google oauth or google login verification
#   * rss
#     - column for following rss feeds
#     - user could add custom rss link rather than suggestion data
#   * linkedin
#     - column for following user's networkin in linkedin
#     - its creation needs oauth verification
#   * podcast
#     - column for following podcast media feeds
#     - user could add custom podcast link rather than selection data
#   * keyword 
#     - column for following tweets based on entered keywords
#     - its creation doesnt need oauth verification
#   * chart / price
#     - column for following price tickers from finfore suggestion

class FeedAccount
  include Mongoid::Document
  include Finforenet::Models::SharedQuery
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  #Fields
  field :name,        :type => String
  field :category,    :type => String
  field :window_type, :type => String,  :default => "tab"
  field :position,    :type => Integer, :default => -1
  
  index :category
  index([[:position, -1]])
  
  #Associations
  belongs_to :user
  embeds_one :feed_token
  embeds_one :keyword_column
  has_many   :user_feeds, :dependent => :destroy, :autosave => true
  
  accepts_nested_attributes_for :keyword_column, :user_feeds, :feed_token
  default_scope asc(:position)
  
  before_create :check_position
  
  validates :category, :presence => true
  validates :name,     :presence => true
  validates :user_id,  :presence => true
  
  def self.owned_by(opts)
    self.includes([:user_feeds]).where(opts)
  end
  
  def create_keyword_column(opts={})
    if opts.keyword.blank?
      self.errors.add(:keyword_column, "should not have empty keyword field.")
    else
      self.keyword_column = KeywordColumn.new(opts)
      self.save
    end
  end
  
  def check_position
    self.position = updated_position if is_positionable?	
  end
  
  # Check whether the column is twitter
  def isTwitter?
    self.category =~ /(tweet|twitter|suggested)/i
  end
  
  # Check whether the column is rss
  def isRss?
    self.category =~ /(rss)/i
  end
  
  def is_positionable?
    self.position < 0 && !isPortfolio?
  end

  # Check whether the column is linkedin
  def isLinkedin?
    self.category =~ /(linkedin|linked-in)/i
  end

  # Check whether the column is podcast
  def isPodcast?
    self.category =~ /(podcast|video|audio)/i
  end

  # Check whether the column is price
  def isChart?
    self.category =~ /(price|chart)/i
  end

  # Check whether the column is company
  def isCompany?
    self.category =~ /(company|index|currency)/i
  end

  # Check whether the column is keyword
  def isKeyword?
    self.category =~ /(keyword)/i
  end

  # Check whether the column is followable to any twitter account
  def isFollowable?
    isTwitter? || isCompany?
  end

  # Check whether the column is portfolio tab
  def isPortfolio?
    self.category =~ /portfolio/i
  end
  
  def isFeedable?
    isPodcast? || isRss? || isCompany?
  end
  
  def hasAggregate?
    isCompany? || isKeyword?
  end
  
  def isFollowable?
    isTwitter? || isCompany?
  end
  
  def isOauth?
    isTwitter? || isGoogle? || isFacebook?
  end
  
  def isFacebook?
    self.category =~ /facebook/i
  end
  
  def isGoogle?
    self.category =~ /(gmail|google|portfolio)/i
  end
  
end
