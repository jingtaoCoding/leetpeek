module LeetcodeClient
  class Request
    
    def initialize(attrs = {})
    end 
    
    LEETCODE_BASE_URL = 'https://leetcode.com/'.freeze
    def response 
        leetcode_connection.send(http_method, path) do |req|
          req.body = request_body.to_json
          leetcode_connection.send(http_method, path)
          req.headers['Content-Type'] = 'application/json'
        end
    end 
    
    private

    def leetcode_connection
      @connection ||= Faraday.new(url: LEETCODE_BASE_URL) do |builder|
        builder.adapter Faraday.default_adapter
      end 
    end 

    def http_method
      :get
    end 

    def request_body
      {}
    end 

    def path
      'problemset/all/'.freeze 
    end 
  end

  class TestRequest < Request
  end 
end 