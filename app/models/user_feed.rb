# User Feed Model is saving information about column's resource such as a rss link, podcast, etc
# User could create their own resource instead of choosing suggestion from finfore
# Parameters:
# Note #1: _id's usage in parameter of feed_info_attributes reffers to suggestion resource id
# feed_info = {title: "BBC Markets",
#              feed_info_attributes: {_id: "3450000001"}
#             }
#
# Note #2: 
# feed_info = {title: "ASIAN Exchanges",
#              feed_info_attributes: {title: "ASIAN Exchange"
#                                     address: "http://rss.asianmarket.net/exchanges.rss"
#                                     category: "rss"}
#             }

class UserFeed
  include Mongoid::Document
  
  field :title, :type => String
  index :title
  index :feed_info_id
  
  # Associations
  belongs_to :feed_account
  belongs_to :feed_info
  
  # It will be used to clone feed_info relation
  embeds_one :custom_feed_info, :class_name => "UserFeed::FeedInfo"
  accepts_nested_attributes_for :custom_feed_info
  
  after_validation :filter_attributes

  def feed_info_attributes(opts)
    @feed_info_attributes = opts
  end

  def feed_info_attributes
    @feed_info_attributes
  end
  
  def before_destroy
    self.feed_info.inc(:follower, -1) if self.feed_info
  end
  
  def after_create
    self.feed_info.inc(:follower, 1)
  end
  
  def feedinfo
    return self.custom_feed_info if self.custom_feed_info.present?
    self.feed_info
  end
  
  def filter_attributes
    if self[:feed_info_attributes].present?
      fi = self[:feed_info_attributes]
      self.unset(:feed_info_attributes)
      if fi[:_id] && self.custom_feed_info.blank?
        self.feed_info_id = BSON::ObjectId(fi[:_id])
      elsif fi[:address].present? && !fi[:_id]
        self.custom_feed_info_attributes = fi
      end if fi.present?
    end
  end

end
