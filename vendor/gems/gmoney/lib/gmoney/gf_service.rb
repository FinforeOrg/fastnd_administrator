require 'net/http'
require 'net/https'
require 'uri'

module GMoney 
  # = GFService
  #
  # Used to send and receive RESTful request/responses from Google
  #
  class GFService 
    def self.send_request(request)
      
      url = URI.parse(request.url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      case request.method
      when :get
        req = Net::HTTP::Get.new(url.request_uri)
      when :put
        req = Net::HTTP::Put.new(url.request_uri)
      when :post
        req = Net::HTTP::Post.new(url.request_uri)
      when :delete
        req = Net::HTTP::Delete.new(url.request_uri)
      else
        raise ArgumentError, "Unsupported HTTP method specified."
      end
      
      req.body = request.body.to_s
      
      request.headers.each do |key, value|
        req[key] = value
      end

      if GFSession.access_token.blank?
        res = http.request(req)

        response = GFResponse.new
        response.body = res.body
        response.headers = Hash.new
        res.each do |key, value|
          response.headers[key] = value
        end

        response.status_code = res.code.to_i
      else
        request.headers.delete("Authorization")
        headers = {}
        request.headers.each do |key, value|
          headers[key] = value.to_s
        end
        
        case request.method
        when :get
          result = GFSession.access_token.get(request.url,headers).body
        when :put
          result = GFSession.access_token.put(request.url,request.body.to_s,headers).body
        when :post
          result = GFSession.access_token.post(request.url,request.body.to_s,headers).body
        when :delete
          result = GFSession.access_token.delete(request.url,headers).body
        else
          raise ArgumentError, "Unsupported HTTP method specified."
        end

        response = GFResponse.new
        response.body = result
        response.headers = headers
        
        err_code = result.to_s.scan(/Error\W+\d{3}/i).shift.to_s.gsub(/Error\W/i,'').to_i
        response.status_code = err_code > 0 ? err_code : 200
      end
      
      return response
    end
  end
end
