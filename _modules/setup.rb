module Setup
  def run
    setup # this
    yield 
    teardown # this
  end

  def setup
    system "clear"
    puts @start_time = Time.now.strftime("%r")
    global_argv # global
    preamble # this
    preface # this
  end

  def teardown
    @browser.quit unless @browser.nil?
    puts end_time = Time.now.strftime("%r")
    time_diff_components = Time.diff(@start_time, end_time, "%m:%s")
    puts "It took #{time_diff_components[:diff]}"
  end

######################################################################

  def preamble # this should be used for all of the scripts
    if ARGV.empty?
      puts "PLEASE GIVE ME ENV".red
      puts "If you only provide one I will compare against production"

      @sc_env_ray.each do |x|
        puts "ruby #{@ruby_file} #{x}"
      end
      
      puts "\nYou can also pass one of the following users\n\n"
      @loaded_user.each do |x|
        print "#{x}, "
      end

      puts "\n\nAnd you can combine multiple arguments\n"
      puts "ruby #{@ruby_file} #{@sc_env_ray[3]} #{@loaded_user[2]} "
      puts "ruby #{@ruby_file} #{@sc_env_ray[1]} pj "
      puts "\n\n"
      abort
    else
    end
  end

  def preface
    yml_domain # global
    ask_mobile_web # global
    load_yml_user # global
    ask_my_profile_uri if @logged_in == "yes" # global
    get_scene # global
    get_base_url #global
#    ask_env # global
  end

  def collecting_tasks
    test_config
    load_test2 # this
    @my_driver == "mw" ? (load_mobile_browser) : (load_desktop) # global
  end

  def reporting_tasks
    load_test # this
    key_urls # this
    yml_urls_empty # this   
  end

######################################################################

def key_urls
  # determine which 'key' urls we want to compare
  puts "Testing #{@test_type}...Loading #{@scene}.yml"
  @yml_urls = []
  @test_urls = YAML::load_file(File.join(__dir__, "../_config/urls/#{@my_domain}/#{@scene}.yml"))
  @test_urls.each do |key, value|
    if ARGV.include? "#{key}"
      @key_url = key
      @yml_urls = value # this will give us just the urls for the ARGV key
    else
    end
  end #@test_urls.each do
  if ARGV.include? "all"
    @yml_urls = @test_urls.values.flatten
  end
end

  def yml_urls_empty
    # if you don't pass ARGV then we ask the user if they want to run against all urls (slow)
    if @yml_urls.empty?
      @test_urls.each do |key, value|
        puts @yml_urls = "ruby #{@ruby_file} #{key}"
      end

      pick_one = ask("Pick one of the url sections to test ").downcase { |q| q.echo = true }
      @test_urls = YAML::load_file(File.join(__dir__, "../_config/urls/#{@my_domain}/#{@scene}.yml"))

      @test_urls.each do |key, value|
        if pick_one.include? "#{key}"
          @key_url = key
          @yml_urls = value # this will give us just the urls for the ARGV key
        else
        end
      end #@test_urls.each do

    else
    end
    @url_count = @yml_urls.count
  end

  def if_logged_in
    if @logged_in == "yes"
      unless @browser.element(:id, "account-options-dropdown").exist?
        puts "Getting logged in"
        get_logged_in
      end
    end
  end

  def goto_page_under_test
    if @my_profile_uri == "y"
      @browser.goto "#{@base_url}#{@my_profile_url}/#{@uri}"
      unless @browser_type == "phantomjs"
        load_secs = @browser.performance.summary[:response_time]/1000
        puts "Load Time: #{load_secs} seconds."
      end
    else
      @browser.goto "#{@base_url}/#{@uri}"
      unless @browser_type == "phantomjs"
        load_secs = @browser.performance.summary[:response_time]/1000
        puts "Load Time: #{load_secs} seconds."
      end
    end # get_comparison
  end

  def load_test
    if ARGV.any? { |x| @test_to_run.include?(x) }
      @test_type = 'ids' if ARGV.include? 'ids'
      @test_type = 'class' if ARGV.include? 'class'
      @test_type = 'analytics' if ARGV.include? 'analytics'
      @test_type = 'dom' if ARGV.include? 'dom'
    else
      @test_type = ''
    end
  end

  def load_test2
    testing = YAML.load(File.read("./_config/config.yml"))
    @ids = testing['ids']
    @class = testing['class']
    @analytics = testing['analytics']
    @dom = testing['dom']
    @seo = testing['seo']
  end

  def url_2_path
    @url_count -= 1
    unless @uri.nil?
      @uri = @uri.gsub('/', '_') if @uri.include?('/')
      @uri = @uri.gsub('?', '_') if @uri.include?('?')
      @uri = @uri[0..99].gsub(/\s\w+\s*$/, '+')
    end
  end

 #
end