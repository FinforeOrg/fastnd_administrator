class Base::FeedInfo
	include Mongoid::Document
	include Finforenet::Models::SharedQuery
	include Finforenet::Models::Jsonable
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
	
	#Fields
	field :title,       :type => String 
	field :address,     :type => String 
	field :category,    :type => String
	field :image,       :type => String 
	field :description, :type => String

	index :title
	index :address
	index :category
	
	validates :address,  :presence => true
	validates :category, :presence => true

end