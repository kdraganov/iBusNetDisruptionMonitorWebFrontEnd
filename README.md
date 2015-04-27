iBus Disruption Monitor Web Fron End Application
===========

Author: Konstantin Draganov
===========

### About
This is a prototypical tool for Real-time visualisation of bus delays in London.
It has been developed as part of my final year MSci Computer Science project supervised by Dr. Steffen Zschaler (http://steffen-zschaler.de/) and it is in collaboration with TFL.

###Execution
To run the project you can simply import it into IntelliJ IDEA IDE (https://www.jetbrains.com/ruby/help/importing-project-from-existing-source-code.html)
and change the database connection settings in config/database.yml

* You need to execute <tt>Bundle install</tt> in order to load all the required gems.

* You need to execute <tt>rake db:migrate</tt> once you have setup the correct settings for connecting to the database.

Once all of the above is done the application can be run with a server of your choice. IntelliJ comes with WebBrick by default which was the server used for developing and testing.

###External libraries used:

* Foundation for rails https://github.com/zurb/foundation-rails
* Will Paginate https://github.com/mislav/will_paginate
* jQuery https://rubygems.org/gems/jquery-rails/versions/4.0.3
* jQuery turbolinks plugin https://github.com/kossnocorp/jquery.turbolinks
* jQuery Datetimepicker https://plugins.jquery.com/datetimepicker/
* Google Charts - jsapi.js https://developers.google.com/chart/

The project is build using Ruby 2.1.5 (https://www.ruby-lang.org/en/) and Rails 4.2.0 (http://rubyonrails.org/). Both of which are required to be installed on the system in order to run the application.

The database used for the development is PostgreSQL 9.4, however if you wish you can use another database, but this needs to be configure according in
the config/database.yml file of this project.

For any questions or problems related to this repository, please feel free to email on konstantinvld@gmail.com
