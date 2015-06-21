# Scenes
public (not logged in)

private (logged in)

profile (logged in user only urls)

# Collection Scripts

    $ ruby collect_elements.rb all stage
    $ ruby collect_elements.rb all stage ray
    $ ruby collect_elements.rb all stage ray profileuri
    
# Comparison

    $ ruby compare_elements.rb all 2 stage ids
    $ ruby compare_elements.rb all 2 stage class
    $ ruby compare_elements.rb all 2 stage analytics
    $ ruby compare_elements.rb all 2 stage dom

    $ ruby compare_elements.rb 4 all stage ray ids
    $ ruby compare_elements.rb 4 all stage ray class
    $ ruby compare_elements.rb 4 all stage ray analytics
    $ ruby compare_elements.rb 4 all stage ray dom
    
# Rake
## collect

    $ rake all env=stage
    #=> this will execute all 3 scenes for Desktop phantomjs

    $ rake all env=stage driver=mw
    #=> this will execute all 3 scenes for Chrome Mobile emulation

## compare
 
    $ rake compare_all num=2 env=stage
    $ rake compare_all num=4 env=stage
