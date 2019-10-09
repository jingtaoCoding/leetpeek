#!/usr/bin/ruby

require 'faraday'

con = Faraday.new :url => "http://www.something.com"

res = con.head 

puts res.headers['server']
puts res.headers['date']
puts res.headers['last-modified']
puts res.headers['content-type']
puts res.headers['content-length']
