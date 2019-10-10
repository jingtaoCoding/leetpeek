# frozen_string_literal: true

require 'faraday'

module LeetcodeClient
  class Request
    attr_accessor :url_base, :connection

    def initialize(request_params = {})
      @connection = nil
      @authentication_token = nil
      @url_base = request_params[:url_base] || 'https://leetcode.com'
    end

    def response
      # leetcode_connection.send(http_method, path) do |req|
      #   req.body = request_body.to_json
      #   leetcode_connection.send(http_method, path)
      #   req.headers['Content-Type'] = 'application/json'
      # end
      leetcode_connection.send(http_method, path)
    end

    private

    def leetcode_connection
      # @connection ||= Faraday.new(url: @url_base) do |builder|
      #   builder.adapter Faraday.default_adapter
      # end
      @connection ||= Faraday.new(url: @url_base) do |builder|
        builder.adapter Faraday.default_adapter
      end
    end

    def http_method
      :get
    end

    def path
      '/problemset/all/'
    end

    def request_body
      {}
    end
  end

  class LoginRequest < Request
    def leetcode_connection
      @connection ||= Faraday.new(url: path) do |conn|
        conn.adapter Faraday.default_adapter
        conn.basic_auth(ENV['LEETCODE_ACCOUNT'], ENV['LEETCODE_KEY'])
      end
    end

    private

    def http_method
      :post
    end

    def path
      @url_base
    end
  end

  class TestRequest < Request
    private

    def path
      '2222'
    end
  end
end

r = LeetcodeClient::Request.new
puts r.response
