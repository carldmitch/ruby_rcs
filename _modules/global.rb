module Global
  def global_argv
    @sc_env_ray = ["al", "al2", "cm", "cm2", "dw", "dw2", "jd", "jd2","kms", "kms2","sg","tri","mservices", "preview", "stage", "prod"]
    @loaded_user = ["abell", "admin", "boyd", "bcrowder", "carl", "cdm001", "cmitchell", "expert", "jeff", "jwinger", "palanis", "ray", "rgivens"]
    @test_to_run = ["dom", "ids", "class", "analytics"]
  end
  
# <------------------------------------------------------------> #
  
  def yml_domain
    if ARGV.any? { |x| ["hca", "hc"].include?(x) }
        @my_domain = "hca"
      unless ARGV.any? { |x| ["pub"].include?(x) }
        @my_yml = "cdm001"
        my_user_creds = YAML.load_file("./_config/sc_users/#{@my_yml}.yml")
        @fname = my_user_creds['fname']
        @lname = my_user_creds['lname']
        @email_address = my_user_creds['email_address']
        @password = my_user_creds['password']
        @logged_in = "yes"
      else
      end
    else
      my_domain = YAML.load(File.read("./_config/config.yml"))
      @my_domain = my_domain['domain']
    end
  end

# <------------------------------------------------------------> #
  
  def ask_mobile_web
    if ARGV.include? "mw"
      @my_driver = "mw"
    else
      @my_driver = "desktop"
    end
  end

# <------------------------------------------------------------> #

  def load_yml_user
    if ARGV.any? do |x|
      @my_yml = x if @loaded_user.include?(x)
      end
      my_user_creds = YAML.load_file("./_config/sc_users/#{@my_yml}.yml")
      @fname = my_user_creds['fname']
      @lname = my_user_creds['lname']
      @email_address = my_user_creds['email_address']
      @password = my_user_creds['password']
      @logged_in = "yes"
  else
      @logged_in = "no"
    end
  end

# <------------------------------------------------------------> #

  def ask_my_profile_uri
    if ARGV.include? "profileuri"
      @myProfileUrl = "$myProfileUrl"
      @my_profile_uri = "y"
    else
#      question = "\nAre you testing with a ProfileUri? ( y or <n>)\n "
#      @my_profile_uri = ask(question).downcase { |q| q.echo = true }
#      if @my_profile_uri == "y"
#        @myProfileUrl = "$myProfileUrl"
#      else
        @my_profile_uri = "n"
#      end
    end
  end

# <------------------------------------------------------------> #

  def load_mobile_browser
    @agent = "Agent: iphone"
    @mobileweb = "MobileWeb "
    @mobilewebset = "_mobileweb "
    @browsersize = "When I set the browser size to 375x667"
    if ARGV.any? { |x| ["headless", "ff"].include?(x) } 
      load_phantomjs_mobile if ARGV.include?("headless")
      load_mobile_firefox_browser if ARGV.include?("ff")
    else
      our_driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :iphone, :orientation => :portrait,)
      @browser = Watir::Browser.new our_driver
    end
    @browser.window.resize_to(320,620) #568
  end

# <------------------------------------------------------------> #

  def profileUri_value
    if @my_profile_uri == "y"
      if @browser.nil?
        @my_driver == "mw" ? (load_mobile_browser) : (load_desktop) # global
        if_logged_in
      else
      end
      puts @my_profile_url = @browser.execute_script("return SC.dataModel.profileUri.value").to_s
    end
  end
# <------------------------------------------------------------> #

  def goto_my_profile_uri
      sleep 2
    if @my_driver == "mw"
      @my_profile_url = @browser.link(:css, "a[title*='profile']").href
      else
      @my_profile_url = @browser.link(:css, "a#account-name").href
    end
    @browser.goto "#{@my_profile_url}/#{@my_uri}"
  end

# <------------------------------------------------------------> #

  def load_desktop
    if ARGV.any? { |x| ["chrome", "ff", "har"].include?(x) } 
      load_chrome_desktop if ARGV.include?("chrome")
      load_firefox_desktop if ARGV.include?("ff")
      load_har_desktop if ARGV.include?("har")
    else
      # We want to load headless browser by default
      load_phantomjs_desktop
    end
  end

# <------------------------------------------------------------> #

  def load_har_desktop
    server = BrowserMob::Proxy::Server.new("./browsermob-proxy-2.1.0-beta-1/bin/browsermob-proxy") #=> #<BrowserMob::Proxy::Server:0x000001022c6ea8 ...>
    server.start
    @proxy = server.create_proxy
    prefs = ["--proxy-server=localhost:#{@proxy.port}"]
    proxy_listener = BrowserMob::Proxy::WebDriverListener.new(@proxy)
    driver = Selenium::WebDriver.for :chrome, :switches => prefs, :listener => proxy_listener
    @browser = Watir::Browser.new driver
  end

# <------------------------------------------------------------> #

  def load_mobile_firefox_browser
    our_driver = Webdriver::UserAgent.driver(:browser => :firefox, :agent => :iphone, :orientation => :portrait,)
    @browser = Watir::Browser.new our_driver
    @browser.window.resize_to(320,620) #568
  end

# <------------------------------------------------------------> #

  def load_chrome_desktop
    @browser =  Watir::Browser.new :chrome
    if ARGV.include? "hide"
      @browser.window.move_to(50,1005)
    else
    end
    if ARGV.include? "big"
    @browser.window.resize_to(1650,1200)
    else
    @browser.window.resize_to(1250,900)
    end
  end

# <------------------------------------------------------------> #
  
  def load_firefox_desktop
    @browser =  Watir::Browser.new :firefox
    @browser.window.resize_to(1650,1200)

    if ARGV.include? "hide"
      @browser.window.move_to(-50,1005)
    else
    end

    if ARGV.include? "big"
      @browser.window.resize_to(1650,1200)
    else
      @browser.window.resize_to(1250,900)
    end
    
  end

# <------------------------------------------------------------> #

  def load_phantomjs_desktop
    @browser =  Watir::Browser.new :phantomjs, :args => ['--ssl-protocol=tlsv1']
    @browser_type = "phantomjs"
  end

# <------------------------------------------------------------> #

  def load_phantomjs_mobile
    capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs
    capabilities['phantomjs.page.customHeaders'] = 'Mozilla/5.0'
    @browser = Watir::Browser.new :phantomjs, :args => ['--ssl-protocol=tlsv1'], desired_capabilities: capabilities
    @browser_type = "phantomjs_mobile"
  end

# <------------------------------------------------------------> #

  def get_base_url
    envs = YAML.load_file("./_config/envs/#{@my_domain}.yml")
    envs.each do | key, value |
      if ARGV.include? key
        @base_url = value
        @env = key
      end
    end
  end
#    case @my_domain
#    when "sharecare"
#      if @env.empty?
#        @base_url = "https://www.sharecare.com"
#      else
#        @base_url = "https://www.#{@env}.sharecare.com"
#      end
#    when "hca"
#      if @env.empty?
#        @base_url = "https://www.hca.sharecare.com"
#      else
#        @base_url = "https://www.#{@env}.hca.sharecare.com"
#      end
#    when 'army'
#      if @env.empty?
#        env = YAML.load_file("../_config/envs_army.yml")
#      
#        env.each do | key, value |
#          puts  @base_url = "#{value}" if ARGV.include? "#{key}"
#        end
#      else
#        puts "now what"
#      end
#    end
#  end

# <------------------------------------------------------------> #

  def get_logged_in
    begin
      @browser.goto "#{@base_url}/login"
      sleep 1
      @browser.text_field(:id, "email").set "#{@email_address}"
      @browser.text_field(:id, "password").set "#{@password}"
      @browser.input(:css, "input[value='Log In']").click
      sleep 2
    rescue
      puts "You must already be logged in"
    end
  end

# <------------------------------------------------------------> #

  def get_registered
    if ARGV.any? { |x| ["register"].include?(x) }
      @registered = "y"
      ask("are you sure?") if @env == ""
      @browser.goto "#{@base_url}/register"
      @browser.text_field(:id, "fname").when_present.set "Ruby"
      lname = Faker::Name.last_name 
      @browser.text_field(:id, "lname").set "#{lname}"
      puts @browser.text_field(:id, "email").set "Ruby#{lname}_#{Time.new.to_i}@cdm.com"
      @browser.text_field(:id, "password").set "gatech21"
      @browser.input(:css, "input[value='Next']").click
# page 2
      sleep 2
      @browser.execute_script("$( '#global-debug-info-toggle' ).remove();")
      @browser.execute_script("$( '#global-debug-info-bar' ).remove();")
      if ARGV.include? "female"
        @browser.span(:text, "Female").when_present.click
      else
        @browser.span(:text, "Male").when_present.click
      end
      if @my_driver == "mw"
        @browser.text_field(:css, ".mobile-dob-input").send_keys "09/10/1973"
      else
        @browser.select_list(:css, "#month").select "Sep"
        @browser.select_list(:css, "#day").select "10"
        @browser.select_list(:css, "#year").select "1973"
      end
      @browser.text_field(:id, "postalCode").set "30019"
      @browser.input(:css, "input[value='Create My Account']").click
      sleep 2
#      @browser.link(:css, "a.onboarding-skip-link").when_present.click
#      @browser.link(:css, "a[href*='user/ruby']").when_present.click
    end
  end

# <------------------------------------------------------------> #

  def get_scene
    @env = "prod" if @env == ""
    @my_driver = "desktop" if @my_driver != "mw"
    case 
    when @logged_in == "yes" && @my_profile_uri == "y"
      @scene = "profile"
    when @logged_in == "yes" && @logged_in == "yes" && @my_profile_uri != "y"
      @scene = "private"
    else
      @scene = "public"
    end
  end

# <------------------------------------------------------------> #

  def show_wait_cursor(seconds,fps=10)
    chars = %w[| / - \\]
    delay = 1.0/fps
    (seconds*fps).round.times{ |i|
      print chars[i % chars.length]
      sleep delay
      print "\b"
      }
  end
 #
end