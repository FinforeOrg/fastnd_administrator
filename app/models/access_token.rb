class AccessToken
  include Mongoid::Document
  
  field :category, :type => String
  field :token,    :type => String
  field :secret,   :type => String
  field :username, :type => String
  
  index :category
  index :username
  
  belongs_to :user
end
