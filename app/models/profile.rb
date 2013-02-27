class Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :title, :type => String
  field :is_private, :type => Boolean, :default => true
  
  index :title
  index :profile_category_id
  
  has_many :user_profiles,      :class_name => "User::Profile",     :dependent => :destroy
  has_many :feed_info_profiles, :class_name => "FeedInfo::Profile", :dependent => :destroy
  belongs_to :profile_category, :index => true
  
  def self.without(disclude)
    self.all(:include=>:profile_category,
             :conditions=>"profile_categories.title !~* '#{disclude}'")
  end

end
