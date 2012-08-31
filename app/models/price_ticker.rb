class PriceTicker
  include Mongoid::Document
  
  field :ticker, :type => String
  field :position, :type => Integer
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
