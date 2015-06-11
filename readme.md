# Collection Scripts

public (not logged in)

private (logged in)

profile (logged in user only urls)

env=
mw=
user=
profile=


    $ ruby collect_elements.rb all stage
    $ ruby collect_elements.rb all stage ray
    $ ruby collect_elements.rb all stage ray profileuri


    $ ruby temp.rb pj stage homepage

##github

    $ ruby collect_elements.rb 
    
# Comparison

    $ ruby compare_elements.rb all 2 stage ids
    $ ruby compare_elements.rb all 2 stage class
    $ ruby compare_elements.rb all 2 stage analytics
    $ ruby compare_elements.rb all 2 stage dom

    $ ruby compare_elements.rb 4 all stage ray ids
    $ ruby compare_elements.rb 4 all stage ray class
    $ ruby compare_elements.rb 4 all stage ray analytics
    $ ruby compare_elements.rb 4 all stage ray dom
    
## Rake

    $ rake compare_all num=2 env=stage
    $ rake compare_all num=4 env=stage
