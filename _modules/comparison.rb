# for comparing env vs env
module Comparison
  def file_ext
    if @test_type == "dom"
      @ext = "html"
    else
      @ext = "log"
    end
  end
  
  def num_of_collections_ago
    if ARGV.any? do |x|
      @num = x.to_i if x == "2" || x == "3" || x == "4" || x == "5" || x == "6" end
    end
  end

  def before_file
    #this is where we need to figure out the comparison directory   second = freq.max_by(2) { |v,l| freq[v] }
    @second_most_recent_path = Dir.glob("../ruby_reports/#{@my_domain}/*/").max_by(@num) {|f| File.mtime(f)}.last
    if @my_driver == "mw"
    puts @file1 = "#{@second_most_recent_path}#{@env}/#{@scene}_#{@my_driver}/#{@test_type}/#{@uri}_.#{@ext}"
#      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
    puts @file1 = "#{@second_most_recent_path}#{@env}/#{@scene}/#{@test_type}/#{@uri}_.#{@ext}"
#      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
  end
  
  def most_recent_path
    #this is where we need to figure out the most recently updated directory  
    @most_recent_path = Dir.glob("../ruby_reports/#{@my_domain}/*/").max_by {|f| File.mtime(f)}
    if @my_driver == "mw"
    puts @file2 = "#{@most_recent_path}#{@env}/#{@scene}_#{@my_driver}/#{@test_type}/#{@uri}_.#{@ext}"
#    puts @file1 = "#{@second_most_recent_path}#{@env}/#{@scene}/#{@test_type}_#{@my_driver}/#{@uri}_.#{@ext}"
#      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}_#{@my_driver}/"
    else
    puts @file2 = "#{@most_recent_path}#{@env}/#{@scene}/#{@test_type}/#{@uri}_.#{@ext}"
#    puts @file1 = "#{@second_most_recent_path}#{@env}/#{@scene}/#{@test_type}/#{@uri}_.#{@ext}"
#      report_path = "../ruby_reports/#{@my_domain}/#{@my_date}/#{@env}/#{@scene}/"
    end
 end
  
  def file_compare(file1,file2)
    if ARGV.include? "test"
      @my_date = Time.now.strftime("%Y_%m_%d_%p_test")
    else
      @my_date = Time.now.strftime("%Y_%m_%d_%p")
    end
    my_report_name = "../ruby_reports/comparisons/#{@my_domain}/#{@my_date}_(#{@num})/#{@env}/#{@scene}_#{@my_driver}/#{@test_type}/"
    FileUtils::mkdir_p my_report_name
    if FileUtils.compare_file(file1, file2)
      puts "no diff"
    else
    difference = Diffy::Diff.new(file1, file2,  :source => 'files').to_s(:html)
      open("#{my_report_name}#{@uri}_.html", 'w') { |f| f.puts "<style>#{Diffy::CSS}</style>" }
      open("#{my_report_name}#{@uri}_.html", 'a') { |f| f.puts "#{@second_most_recent_path}\n" }  
      open("#{my_report_name}#{@uri}_.html", 'a') { |f| f.puts "#{@most_recent_path}\n" }  
      open("#{my_report_name}#{@uri}_.html", 'a') { |f| f.puts difference }  
    end
  end
 #
end
