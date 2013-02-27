source 'http://rubygems.org'

gem 'rails', '3.2.11'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.0.3'
end

#MONITORING
gem 'scout'
gem 'elif'
gem 'request-log-analyzer'
gem 'oink'

# Cross Support
gem 'rack-cors', :require => 'rack/cors', :path => "./vendor/gems/rack-cors"
gem 'crack'

#Database
gem 'mongoid', '2.4.7'
gem 'mongoid-history'
gem 'railroady', :path => "./vendor/gems/railroady"

# Data Support Builders
gem 'xml-simple'
gem 'bson_ext'
gem 'json'
gem 'json_builder'
gem 'jquery-rails'
gem 'yajl-ruby'
gem 'nokogiri', '>= 1.5.0'
gem 'profanity_filter'
gem 'mongoid_voteable'
gem 'mongoid_followable', "~> 0.1.9"

# Background Job & Queue
gem 'resque'
gem 'redis'
gem 'redis-namespace'
gem 'redis-store'

# CSV File Handler
gem 'fastercsv'

# Oauth Authentication
gem 'oauth'
gem 'oauth2'
gem 'twitter_oauth'
gem 'gmail_xoauth', :path => "./vendor/gems/gmail_xoauth"

# User Authentication
gem 'authlogic'

# Social Networking
gem 'gmoney', :path => "./vendor/gems/gmoney"
gem 'linkedin', '0.3.6'
#, :git => 'git://github.com/pengwynn/linkedin.git'
gem 'fgraph'

# Spam Assasin
gem 'akismetor'

# Notification Alert
gem 'exception_notification_rails3', :require => 'exception_notifier'

# Utilities
gem 'execjs'
gem 'therubyracer'
gem 'htmlentities'
gem 'httparty'
gem 'kaminari', '~> 0.14.1'

# Deployment Requirement
gem 'capistrano'
gem 'unicorn'
gem 'foreman'

group :test do
  gem 'factory_girl_rails'
  gem 'cucumber-rails', '>= 1.1.1'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'fuubar'
  #gem 'rcov'
  gem 'simplecov'
  gem "mongoid-rspec", :path => "./vendor/gems/evansagge-mongoid-rspec-1.4.4-13" 
end

group :development do
  gem 'foreman'
  gem 'thin'
  #gem 'rpm_contrib'
  #gem 'newrelic_rpm'
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-doc'
  gem 'awesome_print'
  gem 'letter_opener'
end


