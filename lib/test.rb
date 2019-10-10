#!/usr/bin/ruby
# frozen_string_literal: true

require 'faraday'

list_file = './db/leetcode_list.json'
dst_folder = './db/generated/'

return unless File.exist?(list_file)

list = File.read(list_file)
json = JSON.parse(list)

def create_md_file(output_file, p = {})
  return if p.blank?

  puts p[:id]
  f = File.new(output_file, 'w+')
  f.puts("##{p[:id]}: #{p[:title]}")
  f.puts
  f.puts("## Difficulty: #{p[:difficulty]}")
  f.puts
  f.puts
  f.close
end

json['stat_status_pairs'].each do |x|
  p = {}
  p[:id] = x['stat']['question_id']
  p[:title] = x['stat']['question__title']
  p[:title_slug] = x['stat']['question__title_slug']
  p[:difficulty] = x['difficulty']['level']
  output_file = dst_folder + "leetcode_#{p[:id]}.md"
  next if File.exist?output_file

  create_md_file(output_file, p)
end
