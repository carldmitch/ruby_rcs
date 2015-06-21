require_relative './_modules/global.rb'
require_relative './_modules/setup.rb'
require_relative './_modules/collect.rb'
include Global
include Setup
include Collect
#
require 'selenium-webdriver'
require 'watir-webdriver'
require 'watir-webdriver-performance'
require 'nokogiri'
require 'highline/import'
require 'webdriver-user-agent'
require 'hashdiff'
require 'yaml'
require 'rest-client'
require 'colorize'
require 'awesome_print'
require 'time_diff'
@ruby_file = __FILE__
@my_dir = __dir__
#####################################################


run do
  collecting_tasks # in setup.rb
  reporting_tasks # in setup.rb
  puts "Loading #{@url_count} #{@key_url} urls"
  folder_setup # collect.rb
  @yml_urls.each do |uri|
    @uri = uri
    if_logged_in # setup.rb
    goto_page_under_test # setup.rb
    profileUri_value # global.rb
    puts  @base_url
####################################################
    puts "#{@url_count} #{@browser.url}"
    url_2_path
    @browser.refresh
    sleep 2
    dom_collect if @dom == true
    id_collect_from_html(@dom_filename) if @ids == true
    class_collect_from_html(@dom_filename) if @class == true
    analytics_collect if @analytics == true
    dtm_collect if @dtm == true
    seo_collect(@dom_filename) if @seo == true
  end
 #
end # end run
