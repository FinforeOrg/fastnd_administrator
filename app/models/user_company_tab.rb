class UserCompanyTab
  include Mongoid::Document
  include Finforenet::Models::SharedQuery
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :follower,     :type => Integer
  field :is_aggregate, :type => Boolean, :default => false
  field :position,     :type => Integer, :default => -1
  
  belongs_to :user
  belongs_to :feed_info, :index => true
  
  delegate :title, :to => :feed_info
  delegate :full_name, :to => :user
  
  after_create  :after_creation
  after_destroy :after_deletion

  
  def check_position
	  self.position = updated_position if self.position < 0
  end

  private
    def after_creation
      source = update_feed_info_score(1)
      user.follow(source) if source && !user.follower_of?(source)
    end

    def after_deletion
      source = update_feed_info_score(-1)
      user.unfollow(source) if source && user.follower_of?(source)
    end

    def update_feed_info_score(score)
      source = self.feed_info
      source.vote score, user if can_score_feed_info?(source, score)
      return source
    end

    def can_score_feed_info?(source, score)
      source && ((score > 0 && !source.voted?(user)) || (score < 0 && source.voted?(user)))
    end
  
end
