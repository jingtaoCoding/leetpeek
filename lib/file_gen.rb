#!/usr/bin/ruby
# frozen_string_literal: true

require 'faraday'
module FileGen
  class AnyFile 
    @@init_file = './db/leetcode_list.json'.freeze
    @@dst_folder = './db/generated/'.freeze 
    @@list = nil 
    def self.initialize
      @@list = File.read(@@init_file) if File.exist?@@init_file
    end 
              
    def self.list 
     @@list 
    end 
    
    def self.dst_folder
      @@dst_folder
    end 

    def self.gen(forced = false)
        self.initialize
        return if @@list.blank?
        json = JSON.parse(@@list)
        
        json['stat_status_pairs'].each do |x|
          p = {}
          p[:id] = x['stat']['question_id']
          p[:title] = x['stat']['question__title']
          p[:title_slug] = x['stat']['question__title_slug']
          p[:difficulty] = x['difficulty']['level']
          generator_one_file(p, forced)
        end
    end 

    def self.generator_one_file(p, forced = false )
      'has to implement this'
    end 
  end 
  
  # Generate MarkDown files ---------- 
  class Markdown < AnyFile
      def initialize
      end 

      def self.generator_one_file(p, forced = false )
        output_file = @@dst_folder + "leetcode_#{p[:id]}.md"
        return if (File.exist?output_file) && !forced

        f = File.new(output_file, 'w+')
        f.puts("##{p[:id]}: #{p[:title]}")
        f.puts
        f.puts("## Difficulty: #{p[:difficulty]}")
        f.puts
        f.puts 
        f.close
      end 
  end 
  
  # Generate Anki cards 
  class Anki < AnyFile
      def initialize
      end 

      def self.generator_one_file(p, forced = false )
        output_file = @@dst_folder + "D_#{p[:difficulty]}_leetcode_#{p[:id]}.anki"
        return if (File.exist?output_file) && !forced

        f = File.new(output_file, 'w+')
        f.puts("##{p[:id]}: #{p[:title]}")
        f.puts
        f.puts("## Difficulty: #{p[:difficulty]}")
        f.puts
        f.puts 
        f.close
      end 
  end  
end 

# force update 
# FileGen::Markdown.gen(true) 
FileGen::Anki.gen(true) 
