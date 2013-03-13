class CompanyCompetitor
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :keyword,           :type => String
  field :competitor_ticker, :type => String
  field :company_keyword,   :type => String
  field :broadcast_keyword, :type => String
  field :finance_keyword,   :type => String
  field :bing_keyword,      :type => String
  field :blog_keyword,      :type => String
  field :company_ticker,    :type => String
  
  belongs_to :feed_info, :index => true
  alias :competitor_keyword :keyword
  
  def selected_profiles
    self.feed_info.selected_profiles
  end

  def self.head_table
    %w(competitor_keyword competitor_ticker company_keyword broadcast_keyword finance_keyword bing_keyword blog_keyword company_ticker)
  end
  
end
