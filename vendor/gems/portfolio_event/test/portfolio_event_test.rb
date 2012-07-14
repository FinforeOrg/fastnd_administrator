require 'test_helper'

class PortfolioEventTest < ActiveSupport::TestCase
  should "have respond results" do
    pe = PortfolioEvent.new
    pe.from_ticker('ETR:BMW')
    pe.results.size.should >= 1
  end
end
