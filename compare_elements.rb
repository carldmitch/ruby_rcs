require_relative './_modules/global.rb'
require_relative './_modules/setup.rb'
require_relative './_modules/comparison.rb'
include Global
include Setup
include Comparison
#
#include Collect
#require_relative '../_modules/collect.rb'
#
require 'selenium-webdriver'
require 'watir-webdriver'
require 'watir-webdriver-performance'
require 'nokogiri'
require 'highline/import'
require 'webdriver-user-agent'
require 'diffy'
require 'yaml'
require 'rest-client'
require 'colorize'
require 'awesome_print'
require 'time_diff'
@ruby_file = __FILE__
@my_dir = __dir__
#####################################################


run do
  reporting_tasks
  puts "Loading #{@url_count} #{@key_url} urls"
  @yml_urls.each do |uri|
    begin
      @uri = uri
      profileUri_value
      puts "#{@url_count}"
      url_2_path
####################################################
      # use 2 to compare two most recent
      # use 3 to compare third most recent again most recent
      file_ext
      num_of_collections_ago
      before_file
      most_recent_path
      file_compare(@file1,@file2)
    rescue
    puts($!, $@)
      next
    end
  end
 #
end # end run
