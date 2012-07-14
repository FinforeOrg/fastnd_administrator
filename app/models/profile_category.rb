class ProfileCategory
  include Mongoid::Document
  
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
