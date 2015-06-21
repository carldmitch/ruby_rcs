#Global module for collecting stuff for comparison
module Collect
  def collection_path
    if @my_driver == "mw"
      @report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
      @report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
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
  end
  
  def seo_collect(file) # WIP
    script_type = "seo"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts '  Collecting seo elements'
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

  def id_collect_from_html(file)
    script_type = "ids"
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"

    if !(File.exist?(filename))
      puts '  Collecting ids'
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      file_ids = Nokogiri::HTML(open(file))
      ids = file_ids.css("[id]")
        ids.each do |id|
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
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"
    
    if !(File.exist?(filename))
      puts '  Collecting classes'
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      file_classes = Nokogiri::HTML(open(file))
      classes = file_classes.css("[class]")
      classes.shift
      class_ray = classes.collect do |c|
        c["class"]
      end
      class_ray.uniq!    
      class_ray.each do |c|
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
    collection_path
    FileUtils::mkdir_p "#{@report_path}#{script_type}"
    filename = "#{@report_path}#{script_type}/#{@uri}_.log"

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
                when line.start_with?('https://smetrics')
                    open(filename, 'a') { |f| f.puts line[0...-15] }
                else
                open(filename, 'a') { |f| f.puts line }
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
      puts '  Collecting dtm'
    if !(File.exist?(filename))
      open(filename, 'w') { |f| f.puts "#{@browser.url}" }
      timing = @browser.execute_script("return window.performance.getEntries()")
      timing.each do |t_hash|
        t_hash.each do |t|
          if t.to_s.include? "b/ss/"
            t_call = t[1]
            sub_t_call = t_call.gsub('?',"\n")
            sub_t_call = sub_t_call.gsub('&',"\n")
            sub_t_call = URI.unescape(sub_t_call)
            if t_call.include? "sharecaredtm"
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
                when line.start_with?('https://smetrics')
                    open(filename, 'a') { |f| f.puts line[0...-15] }
                else
                  open(filename, 'a') { |f| f.puts line }
                end
              end
            end
          end
        end
      end
    end
      puts '  Already collected the dtm calls'
  end
 #
#last
end
  