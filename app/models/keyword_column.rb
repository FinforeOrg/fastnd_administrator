class KeywordColumn
  include Mongoid::Document
  
  field :keyword,      :type => String
  field :is_aggregate, :type => Boolean, :default => false
  field :follower,     :type => Integer, :default => 0
  
  index :keyword
  
  validates :keyword, :presence => true

  embedded_in :feed_account
  
end
