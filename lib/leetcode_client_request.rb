require 'faraday'

module LeetcodeClient
  class Request
    attr_accessor :url_base

    def initialize(attrs = {})
      @url_base = attrs[:url_base] || 'https://leetcode.com/'
    end 
    
    def response 
        leetcode_connection.send(http_method, path) do |req|
          req.body = request_body.to_json
          leetcode_connection.send(http_method, path)
          req.headers['Content-Type'] = 'application/json'
        end
    end 
    
    # private

    def leetcode_connection
      @connection ||= Faraday.new(url: @url_base) do |builder|
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

