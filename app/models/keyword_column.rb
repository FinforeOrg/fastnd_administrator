class KeywordColumn
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :keyword,      :type => String
  field :is_aggregate, :type => Boolean, :default => false
  field :follower,     :type => Integer, :default => 0
  
  index :keyword
  
  validates :keyword, :presence => true

  embedded_in :feed_account
  
end
