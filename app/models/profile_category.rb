class ProfileCategory
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
                  
  field :title, :type => String
  
  has_many :profiles
  
  def self.with_public_profile
    self.includes(:profiles)
  end
  
  private
    def self.public_opts
      {"profiles.is_private" => {"$ne" => true}}
    end

end
