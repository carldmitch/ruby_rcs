#Global module for collecting stuff for comparison
module Collect
  def folder_setup
    if ARGV.include? "test"
      @my_date = Time.now.strftime("%Y_%m_%d_%p_test")
    else
      @my_date = Time.now.strftime("%Y_%m_%d_%p")
    end
    #
    if @my_driver == "mw"
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
    FileUtils::mkdir_p "#{report_path}"
    count_file = "#{report_path}_#{@url_count}_.count"
    open(count_file, 'w') { |f| f.puts @url_count }
  end
  
  def test_config
    my_config = YAML.load(File.read("./_config/config.yml"))
    @dom ||= my_config['dom']
    @ids ||= my_config['ids']
    @class ||= my_config['class']
    @seo ||= my_config['seo']
    @analytics ||= my_config['analytics']
    @dtm ||= my_config['dtm']
  end
  
  def dom_collect
    script_type = "dom"
      if @my_driver == "mw"
        report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
      else
        report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
      end
    FileUtils::mkdir_p "#{report_path}#{script_type}"
    filename = "#{report_path}#{script_type}/#{@uri}_.html"
    
    if !(File.exist?(filename))
      puts '  Collecting DOM'
      sleep 1
      open(filename, 'w') { |f| f.puts @browser.html }
    else
      puts '  Already collected this DOM'
    end
    @dom_filename = filename
  end

  def css_text(node)
    node_css = @file_seo.css(node)
        return "#{node}: [ #{node_css.count} ] #{node_css.text.gsub(/\A\s{2,}/, ' ')}" unless node_css.empty?    
#    return "#{node}: [ #{node_css.count} ] #{node_css.text.strip}" unless node_css.empty?    
  end
  
  def seo_collect(file) # WIP
    script_type = "seo"
    if @my_driver == "mw"
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
    FileUtils::mkdir_p "#{report_path}#{script_type}"
    filename = "#{report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts '  Collecting seo elements'
#      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      @file_seo = Nokogiri::HTML(open(file))
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      open(filename, 'a') { |f| f.puts "#{css_text('title')}" } unless css_text('title').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h1')}" } unless css_text('h1').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h2')}" } unless css_text('h2').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h3')}" } unless css_text('h3').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h4')}" } unless css_text('h4').blank?
      open(filename, 'a') { |f| f.puts "canonical: #{@file_seo.css('link[rel=canonical]').count}" }
      open(filename, 'a') { |f| f.puts "canonical: #{@file_seo.css('link[rel=canonical]').attr('href')}" }
    end
  end

  def id_collect_from_html(file)
    script_type = "ids"
    if @my_driver == "mw"
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
    FileUtils::mkdir_p "#{report_path}#{script_type}"
#    id_file = "#{report_path}#{script_type}_#{@url_count}_.count"
    filename = "#{report_path}#{script_type}/#{@uri}_.log"

    if !(File.exist?(filename))
      puts '  Collecting ids'
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      file_ids = Nokogiri::HTML(open(file))
      ids = file_ids.css("[id]")
        id_ray = ids.each do |id|
          unless id["id"].include? "frame"
            open(filename, 'a') { |f| f.puts "#{id["id"]}" }
          end
        end
    else
    puts '  Already collected these ids'
    end
  end

  def class_collect_from_html(file)
    script_type = "class"
    if @my_driver == "mw"
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
    FileUtils::mkdir_p "#{report_path}#{script_type}"
#    class_file = "#{report_path}#{script_type}_#{@url_count}_.count"
    filename = "#{report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts '  Collecting classes'
#      open(class_file, 'w') { |f| f.puts @url_count }
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      file_classes = Nokogiri::HTML(open(file))
      classes = file_classes.css("[class]")
      classes.shift
      class_ray = classes.collect do |c|
        c["class"]
      end
      class_ray.uniq!    
      uniq_class_ray = class_ray.each do |c|
        unless c.blank?
        open(filename, 'a') { |f| f.puts "#{c}" }
        end
      end
    else
      puts '  Already collected these classes'
      return class_ray
    end
  end

  def analytics_collect
    script_type = "analytics"
    if @my_driver == "mw"
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
    FileUtils::mkdir_p "#{report_path}#{script_type}"
    filename = "#{report_path}#{script_type}/#{@uri}_.log"

    if !(File.exist?(filename))
      puts '  Collecting analytics'
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      timing = @browser.execute_script("return window.performance.getEntries()")
      timing.each do |t_hash|
        t_hash.each do |t|
          if t.to_s.include? "b/ss/"
            t_call = t[1]
            sub_t_call = t_call.gsub('?',"\n")
            sub_t_call = sub_t_call.gsub('&',"\n")
            sub_t_call = URI.unescape(sub_t_call)
            unless t_call.include? "sharecaredtm"
              open(filename, 'a') { |f| f.puts sub_t_call }
            end
          end
        end
      end
      puts '  Already collected the analytic call'
    end

#    script_type = "analytics"
#    if @my_driver == "mw"
#      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
#    else
#      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
#    end
#    FileUtils::mkdir_p "#{report_path}#{script_type}"
##    analytics_file = "#{report_path}#{script_type}_#{@url_count}_.count"
#    filename = "#{report_path}#{script_type}/#{@uri}_.log"
#    
#    if !(File.exist?(filename))
#      puts '  Collecting analytics'
#      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
#      tags_ray = YAML.load_file(File.join(__dir__, '../_config/analytics/analytics_all_tags.yml'))
#
#      tags_ray.each do |tag| # BEGIN tags_ray
#        begin
#          value = @browser.execute_script("return s.#{tag}").to_s
#          unless value.nil? || value == '' || # BEGIN unless value.nil
#            open(filename, 'a') { |f| f.puts "#{tag}:#{value}" }
#          end
#        rescue
#          puts($!, $@)
#          next
#        end
#      end
#    else
#      puts '  Already collected these analytics'
#    end
  end

  def dtm_collect
    script_type = "dtm"
    if @my_driver == "mw"
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
    FileUtils::mkdir_p "#{report_path}#{script_type}"
    filename = "#{report_path}#{script_type}/#{@uri}_.log"
#    dtm_filename = "#{report_path}#{script_type}/#{@uri}_dtm.log"

    if !(File.exist?(filename))
      puts '  Collecting dtm'
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
#      open(dtm_filename, 'w') { |f| f.puts "#{@browser.url}" }
      timing = @browser.execute_script("return window.performance.getEntries()")
      timing.each do |t_hash|
        t_hash.each do |t|
          if t.to_s.include? "b/ss/"
            t_call = t[1]
            sub_t_call = t_call.gsub('?',"\n")
            sub_t_call = sub_t_call.gsub('&',"\n")
            sub_t_call = URI.unescape(sub_t_call)
            if t_call.include? "sharecaredtm"
              open(filename, 'a') { |f| f.puts sub_t_call }
#              open(dtm_filename, 'a') { |f| f.puts sub_t_call }
            else
            end
          end
        end
      end
      puts '  Already collected the dtm calls'
    end
  end

  def screenshot_collect
    filename = "#{@report_path}screenshots/#{@uri}_ss.png"
    if !(File.exist?(filename))
      puts '  Collecting SCREENSHOT'
      @browser.execute_script("$( '#global-debug-info-toggle' ).remove();")
      @browser.execute_script("$( '#global-debug-info-bar' ).remove();")
      sleep 1
      #take screenshot
      screenshot = filename
      @browser.screenshot.save screenshot
    else
      puts '  Already taken Screenshot'
    end
  end
 #
end
  