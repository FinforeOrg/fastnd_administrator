require "net/https"
require "net/https"
require "uri"

class PortfolioEvent
  VERSION  = '0.0.1'

  def initialize
    @results = []
    @tickers = []
    @uri = URI.parse("http://www.google.com/finance/events")
    @http = Net::HTTP.new(@uri.host, @uri.port)
  end

  def from_ticker(ticker)
    @tickers = ticker.class == String ? [ticker] : ticker
    search_events
  end

  def results
    @results
  end

  private
    def search_events
      if @tickers.first
        @uri.query = "output=json&q=" + @tickers.first.to_s
        request = Net::HTTP::Get.new(@uri.request_uri)
        response = @http.request(request)
        if response.code == "200"
          begin
          agenda = ActiveSupport::JSON.decode response.body
          rescue
            require 'activesupport'
            agenda = ActiveSupport::JSON.decode response.body
          end
          @results.concat(agenda["events"]) if agenda["events"] && agenda["events"].size > 0
        end
        @tickers.shift
        search_events
      else
        filter_and_sort_results
      end
    end

    def filter_and_sort_results

      @results = @results.reject{|result| ((result["LocalizedInfo"]["start_date"].to_date.month < Date.today.month-1 &&
                                            result["LocalizedInfo"]["start_date"].to_date.year >= Date.today.year) ||
                                            result["LocalizedInfo"]["start_date"].to_date.year < Date.today.year)
                                }.sort_by{|event| event["LocalizedInfo"]["start_date"].to_date} if @results.size > 1
    end

end
