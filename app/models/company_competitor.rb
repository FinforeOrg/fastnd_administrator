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
  
  def selected_profiles
    self.feed_info.selected_profiles
  end
  
end
