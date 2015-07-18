# Scenes
public (not logged in)

private (logged in)

profile (logged in user only urls)

# Collection Scripts

    $ ruby collect_elements.rb all stage
    #=> public
    $ ruby collect_elements.rb all ray stage
    #=> private
    $ ruby collect_elements.rb all ray profileuri stage
    #=> profile

    $ ruby collect_elements.rb all stage mw
    #=> public_mw
    $ ruby collect_elements.rb all stage ray mw
    #=> private_mw
    $ ruby collect_elements.rb all stage ray profileuri mw
    #=> profile_mw
    
    $ ruby collect_elements.rb all stage mw test
    
# Comparison

    $ ruby compare_elements.rb all 2 stage elements
    $ ruby compare_elements.rb all 2 stage analytics
    $ ruby compare_elements.rb all 2 stage dtm

    $ ruby compare_elements.rb 4 all stage ray elements
    $ ruby compare_elements.rb 4 all stage ray analytics
    $ ruby compare_elements.rb 4 all stage ray dtm
    
# Rake
## collect

    $ rake all env=stage
    #=> this will execute all 3 scenes for Desktop phantomjs

    $ rake all env=stage driver=mw
    #=> this will execute all 3 scenes for Chrome Mobile emulation

## compare
 
    $ rake compare_all num=2 env=stage
    $ rake compare_all num=2 env=stage driver=mw
    $ rake compare_all num=4 env=stage
    
## clean up empty files

    #=> execute from env directory (eg. 'stage')
    $ find . -type f -size -160c
    #=> returns small files that might need re-run
    $ find . -type f -size -160c | grep dtm
    #=> returns only dtm small files that might need re-run
    $ find . -type f -size -160c -delete
    #=> deletes small files so they can be re-run
    