class PriceTicker
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :ticker, :type => String
  field :position, :type => Integer
  index :position
  index :ticker
  
  belongs_to :feed_info, :index => true
  before_save :before_saving

  default_scope asc(:position)

  private
  def before_saving
    if self.valid? and self.position.blank?
      lastest = self.feed_info.price_tickers.desc(:position).first
      self.position = lastest ? (lastest.position.to_i + 1) : 1
    end
  end

end
