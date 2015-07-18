#Global module for collecting stuff for comparison
module Collect
  def collection_path
    if @my_driver == "mw"
      if @test_type == 'screenshot'
        @report_path = "#{Dir.home}/ruby_screenshots/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
      else
        @report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
      end
    else
      if @test_type == 'screenshot'
        @report_path = "#{Dir.home}/ruby_screenshots/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
      else
        @report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
      end
    end
  end
  
  def folder_setup
    if ARGV.include? "test"
      @my_date = Time.now.strftime("%Y_%m_%d_%p_test")
    else
      @my_date = Time.now.strftime("%Y_%m_%d_%p")
    end
    #
    collection_path
    FileUtils::mkdir_p "#{@report_path}"
    count_file = "#{@report_path}_#{@key_url}_#{@url_count}_.count"
    open(count_file, 'w') { |f| f.puts @url_count }
  end
  
  def test_config
    my_config = YAML.load(File.read("./_config/config.yml"))
    @dom ||= my_config['dom']
    @ids ||= my_config['ids']
    @class ||= my_config['class']
    @elements ||= my_config['elements']
    @seo ||= my_config['seo']
    @analytics ||= my_config['analytics']
    @dtm ||= my_config['dtm']
  end
  
  def dom_collect
    script_type = "dom"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.html"
    
    if !(File.exist?(filename))
      puts "  Collecting DOM  #{filename}"
      sleep 3
      open(filename, 'w') { |f| f.puts @browser.html }
      
    else
      puts '  Already collected this DOM'
    end
    @dom_filename = filename
  end

  def screenshot_collect
    script_type = "screenshot"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.png"
    
    if !(File.exist?(filename))
      puts "  Collecting #{script_type}  #{filename}"
      sleep 1
      @browser.execute_script "$( '#global-debug-info-toggle' ).remove();"
      @browser.execute_script "$( '#global-debug-info-bar' ).remove();"
      sleep 2
      @browser.screenshot.save filename
    else
      puts "  Already collected this #{script_type}"
    end
    # @dom_filename = filename
  end

  def css_text(node)
    node_css = @file_seo.css(node)
        return "#{node}: [ #{node_css.count} ] #{node_css.text.gsub(/\A\s{2,}/, ' ')}" unless node_css.empty?    
  end
  
  def element_collect_from_html
    script_type = "elements"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts "  Collecting elements  #{filename}"
      @browser.element(:css, '#sharecare-footer').wait_until_present
      sleep 1
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      doc = WatirNokogiri::Document.new(@browser.html)
      my_ray = doc.elements.collect do |elem|
        "#{elem.id}.#{elem.attribute_value('class')}"
      end
      my_ray.reject! { |c| c.empty? } # removes the blank elements from array
      my_ray.uniq! # removes duplicates
      my_ray.shift # removes the first one
      done = my_ray.map{|elem| elem.gsub(/\s+/, '.') }
      done.shift
      done.each do |x|
        if x.nil? or
           x == "" or 
           x.empty? or
           x.start_with? "pr" or
           x.include? "google" or
           x.include? "iframe" or
           x.include? "001" or
           x.include? "easyXDM_" or 
           x.include? "D00D" or 
           x.include? "debug" or 
           x.include? "D5120500" or
           x.include? "I0_" or
           x.include? "oauth2relay"
        else
          if x.end_with?('.')
            x = x[0...-1]
          end
          if x.start_with?('.')
            open(filename, 'a') { |f| f.puts "#{x}" }
          else
            open(filename, 'a') { |f| f.puts "##{x}" }
          end        
        end
      end
    else
      puts '  Already collected these elements'
    end
  end

  def analytics_collect
    script_type = "analytics"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"

    if !(File.exist?(filename))
      puts "  Collecting analytics  #{filename}"
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      #
      #
            begin
              timing = @browser.execute_script("return window.performance.getEntries()")
              sleep 1
            end while timing.include? "event4"
      #
      #
      timing = @browser.execute_script("return window.performance.getEntries()")
      timing.each do |t_hash|
        t_hash.each do |t|
          if t.to_s.include? "b/ss/"
            t_call = t[1]
            sub_t_call = t_call.gsub('?',"\n")
            sub_t_call = sub_t_call.gsub('&',"\n")
            sub_t_call = URI.unescape(sub_t_call)
            unless t_call.include? "sharecaredtm"
              # for sharecare this should include only the s.t() page load calls
              if t_call.include? "event4"
              sub_t_call.each_line do |line|
                # I want to exclue the values that return days and times so the compare script won't 
                case
                when line.start_with?('t=')
                  # do nothing
                when line.start_with?('t=')
                  # do nothing
                when line.start_with?('c21')
                  if line =~ /c21=\d+:\d+(AM|PM)/
                    open(filename, 'a') { |f| f.puts 'c21=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c21=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v21')
                  if line =~ /v21=\d+:\d+(AM|PM)/
                    open(filename, 'a') { |f| f.puts 'v21=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v21=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('c22')
                  if line =~ /c22=\w+day$/
                    open(filename, 'a') { |f| f.puts 'c22=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c22=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v22')
                  if line =~ /v22=\w+day$/
                    open(filename, 'a') { |f| f.puts 'v22=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v22=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('c23')
                  if line =~ /c23=Week(day|end)/
                    open(filename, 'a') { |f| f.puts 'c23=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c23=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v23')
                  if line =~ /v23=Week(day|end)/
                    open(filename, 'a') { |f| f.puts 'v23=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v23=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('bh')
                  if line =~ /bh=\d+/
                    open(filename, 'a') { |f| f.puts 'bh=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "bh=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('https://smetrics')
                    open(filename, 'a') { |f| f.puts line[0...49 ] }
                else
                open(filename, 'a') { |f| f.puts line }
                end
              end
              end
            end
          end
        end
      end
     else
      puts '  Already collected the analytics call'
    end
  end

  def dtm_collect
    script_type = "dtm"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    sleep 5
    if !(File.exist?(filename))
      puts "  Collecting dtm  #{filename}"
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      if @browser.element(:css, 'a.button.fancybox-close').exists?
        @browser.element(:css, 'a.button.fancybox-close').click
        @browser.refresh
      else
        @browser.refresh
      end
#
      begin
        timing = @browser.execute_script("return window.performance.getEntries()")
        sleep 2
      end while timing.include? "event4"
#
      timing = @browser.execute_script("return window.performance.getEntries()")
      timing.each do |t_hash|
        t_hash.each do |t|
          if t.to_s.include? "b/ss/"
            t_call = t[1]
            sub_t_call = t_call.gsub('?',"\n")
            sub_t_call = sub_t_call.gsub('&',"\n")
            sub_t_call = URI.unescape(sub_t_call)
            # for sharecare this should return only the one dtm call
            if t_call.include? "sharecaredtm"
              # for sharecare this should include only the s.t() page load calls
              # if t_call.include? "event4"
              sub_t_call.each_line do |line|
                # I want to exclue the values that return days and times so the compare script won't 
                case
                when line.start_with?('t=')
                  # do nothing
                when line.start_with?('fid=')
                  # do nothing
                when line.start_with?('c21')
                  if line =~ /c21=\d+:\d+(AM|PM)/
                    open(filename, 'a') { |f| f.puts 'c21=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c21=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v21')
                  if line =~ /v21=\d+:\d+(AM|PM)/
                    open(filename, 'a') { |f| f.puts 'v21=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v21=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('c22')
                  if line =~ /c22=\w+day$/
                    open(filename, 'a') { |f| f.puts 'c22=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c22=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v22')
                  if line =~ /v22=\w+day$/
                    open(filename, 'a') { |f| f.puts 'v22=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v22=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('c23')
                  if line =~ /c23=Week(day|end)/
                    open(filename, 'a') { |f| f.puts 'c23=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c23=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v23')
                  if line =~ /v23=Week(day|end)/
                    open(filename, 'a') { |f| f.puts 'v23=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v23=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('bh')
                  if line =~ /bh=\d+/
                    open(filename, 'a') { |f| f.puts 'bh=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "bh=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('https://smetrics')
                    open(filename, 'a') { |f| f.puts line[0...52 ] }
                else
                  open(filename, 'a') { |f| f.puts line }
                end
              end
              # end
            end
          end
        end
      end
    else
      puts '  Already collected the dtm calls'
    end
  end

  def id_collect_from_html(file)
    script_type = "ids"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"

    if !(File.exist?(filename))
      puts '  Collecting ids'
      sleep 2
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      file_ids = Nokogiri::HTML(open(file))
      ids = file_ids.css("[id]")
        ids.each do |id|
          id_text = id["id"]
          unless id_text.include? "frame" or
                 id_text.empty?
                 if @browser.element(:id, id_text).visible?
                   open(filename, 'a') { |f| f.puts id_text }
                 end
          end
        end
    else
    puts '  Already collected these ids'
    end
  end

  def class_collect_from_html(file)
    script_type = "class"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts '  Collecting classes'
      sleep 2
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      file_classes = Nokogiri::HTML(open(file))
      classes = file_classes.css("[class]")
      classes.shift
      class_ray = classes.collect do |c|
        c["class"]
      end
      class_ray.uniq!    
      class_ray.each do |c|
        unless c.blank? or c.start_with? "pr"
        open(filename, 'a') { |f| f.puts "#{c}" }
        end
      end
    else
      puts '  Already collected these classes'
      return class_ray
    end
  end

  def onclick_collect
    script_type = "onclick"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    dtm_filename = "#{@report_path}#{script_type}_dtm/#{@uri}_.log"

    if !(File.exist?(filename))
      puts '  Collecting analytics'
      sleep 2
      #=>
@uri = url_path
@uri = @uri.gsub('/', '_') if @uri.include?('/')
@uri = @uri.gsub('?', '_') if @uri.include?('?')
@uri = @uri[0..99].gsub(/\s\w+\s*$/, '+')
@browser.goto "https://www.stage.sharecare.com/#{url_path}"
@browser.execute_script("$( '#global-debug-info-toggle' ).remove();")
@browser.execute_script("$( '#global-debug-info-bar' ).remove();")
#
#=> opens onclick in new tab, focuses it, then closes extra window
@browser.element(:css, "#{selector}").click(:command, :shift)
sleep 1
@browser.windows.last.use
@browser.send_keys(:command, 'w')
@browser.windows.last.use
#

      #=>
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
              sub_t_call.each_line do |line|
                # I want to exclue the values that return days and times so the compare script won't 
                case
                when line.start_with?('t=')
                  # do nothing
                when line.start_with?('c21')
                  if line =~ /c21=\d+:\d+(AM|PM)/
                    open(filename, 'a') { |f| f.puts 'c21=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c21=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v21')
                  if line =~ /v21=\d+:\d+(AM|PM)/
                    open(filename, 'a') { |f| f.puts 'v21=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v21=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('c22')
                  if line =~ /c22=\w+day$/
                    open(filename, 'a') { |f| f.puts 'c22=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c22=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v22')
                  if line =~ /v22=\w+day$/
                    open(filename, 'a') { |f| f.puts 'v22=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v22=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('c23')
                  if line =~ /c23=Week(day|end)/
                    open(filename, 'a') { |f| f.puts 'c23=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "c23=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('v23')
                  if line =~ /v23=Week(day|end)/
                    open(filename, 'a') { |f| f.puts 'v23=validated within ruby script' }
                  else
                    open(filename, 'a') { |f| f.puts "v23=ERROR VALIDATE MANUALLY #{Time.now}" }
                  end
                when line.start_with?('https://smetrics')
                    open(filename, 'a') { |f| f.puts line[0...-16] }
                else
                open(filename, 'a') { |f| f.puts line }
                end
              end
            end
          end
        end
      end
     else
      puts '  Already collected the onclicks call'
    end
  end
  
  def seo_collect(file) # WIP
    script_type = "seo"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts '  Collecting seo elements'
      sleep 2
      @file_seo = Nokogiri::HTML(open(file))
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      open(filename, 'a') { |f| f.puts "#{css_text('title')}" } unless css_text('title').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h1')}" } unless css_text('h1').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h2')}" } unless css_text('h2').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h3')}" } unless css_text('h3').blank?
      open(filename, 'a') { |f| f.puts "#{css_text('h4')}" } unless css_text('h4').blank?
      open(filename, 'a') { |f| f.puts "canonical: #{@file_seo.css('link[rel=canonical]').count}" }
      open(filename, 'a') { |f| f.puts "canonical: #{@file_seo.css('link[rel=canonical]').attr('href')}" }
    else
    puts '  Already collected seo'
    end
  end

 #
#last
end
  