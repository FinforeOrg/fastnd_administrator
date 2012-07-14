class UserCompanyTab
  include Mongoid::Document
  include Finforenet::Models::SharedQuery
  
  field :follower,     :type => Integer
  field :is_aggregate, :type => Boolean, :default => false
  field :position,     :type => Integer, :default => -1
  
  belongs_to :user
  belongs_to :feed_info, :index => true
  
  default_scope asc(:position)
  before_create :check_position
  
  def check_position
	  self.position = updated_position if self.position < 0
  end
  
end
