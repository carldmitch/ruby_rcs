# rake all env=stage 
#
# rake collect env=stage browser=chrome scene=enhanced-profile
desc "env= This will run the collection script against the 'public' urls"
task :collect do
  ruby "collect_elements.rb #{ENV['env']} #{ENV['browser']} #{ENV['scene']}" rescue puts($!, $@)
end
#######################
# rake public env=prod driver=mw
desc "env= This will run the collection script against the 'public' urls"
task :public do
  ruby "collect_elements.rb all #{ENV['env']} #{ENV['browser']} #{ENV['test']} #{ENV['driver']}" rescue puts($!, $@)
end
#
# rake private env=stage driver=mw
desc "env= This will run the collection script against the 'private' urls"
task :private do
  ruby "collect_elements.rb all ray #{ENV['env']} #{ENV['browser']} #{ENV['test']} #{ENV['driver']}" rescue puts($!, $@) 
end
#
# rake profileuri env=stage driver=mw
desc "env= This will run the collection script against the 'profile' urls"
task :profileuri do
  ruby "collect_elements.rb all ray profileuri #{ENV['env']} #{ENV['browser']} #{ENV['test']} #{ENV['driver']}" rescue puts($!, $@) 
end
###
# rake all env=stage driver=mw
# rake all env=stage 
desc "env=  This will run each of the 3 scripts one at a time"
task :all => [] do
    Rake::Task[:public].execute 1
    Rake::Task[:private].execute 2
    Rake::Task[:profileuri].execute 3
end

# rake compare_all num=2 env=stage test=ids
# rake compare_all num=2 env=stage test=ids
# rake compare_all num=2 env=stage test=ids
# rake compare_all num=2 env=stage user=ray
# rake compare_all num=2 env=stage user=ray scene=profileuri
desc "Default rake task"
task :compare do
  ruby "compare_elements.rb all #{ENV['num']} #{ENV['env']} #{ENV['test']} #{ENV['user']} #{ENV['scene']}" rescue puts($!, $@) 
end
#
#rake compare_all num=2 env=stage
#rake compare_all num=2 env=stage driver=mw
#rake compare_all num=4 env=stage
desc "rake compare_all num=2 env=stage"
task :compare_all do
  ruby "compare_elements.rb all ids #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all class #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all analytics #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
#  ruby "compare_elements.rb all dom #{ENV['num']} #{ENV['env']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all ids ray #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all class ray #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all analytics ray #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
#  ruby "compare_elements.rb all dom ray #{ENV['num']} #{ENV['env']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all ids ray profileuri #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all class ray profileuri #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
  ruby "compare_elements.rb all analytics ray profileuri #{ENV['num']} #{ENV['env']} #{ENV['driver']}" rescue puts($!, $@) 
#  ruby "compare_elements.rb all dom ray profileuri #{ENV['num']} #{ENV['env']}" rescue puts($!, $@) 
end
#
## rake single env=stage 
##
#desc "This will run the 3 main scenes one at a time"
#task :collect_one_by_one do
#  ruby "compare_elements.rb all #{ENV['env']}" rescue puts($!, $@) 
#  ruby "compare_elements.rb all ray #{ENV['env']}" rescue puts($!, $@) 
#  ruby "compare_elements.rb all ray profileuri #{ENV['env']}" rescue puts($!, $@) 
#end

#compare_elements.rb all stage analytics
#compare_elements.rb all stage ids
#compare_elements.rb all stage class
#compare_elements.rb all stage dom