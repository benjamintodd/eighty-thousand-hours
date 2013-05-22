source 'http://rubygems.org'

gem 'rails', '>= 3.2.11'

# rake
gem "rake", ">= 10.0.3"

# user login
gem 'devise'

# postgresql
gem 'pg'

# for nice url slugs
gem 'friendly_id', '>= 4.0.0.rc2'

# authorisation
gem 'cancan'

# for uploading profile pictures
gem 'aws-sdk'
gem 'aws-s3'
gem 'paperclip', '~> 2.4'

# markdown
gem "maruku", "~> 0.6.0"

# production-ready web server for heroku cedar stack
gem 'thin'

# emails us when the production app fails
gem 'exception_notification', "2.6.1"

# sweet templating language
gem "haml"

# tranlations and localisations
gem 'rails-i18n'

# admin pages
gem 'activeadmin'

# lightbox gem
gem 'fancybox-rails'

# for versioning of content
gem 'paper_trail', '~> 2'

# blog post pagination
gem 'will_paginate', '~> 3.0'

# tags for blog posts
gem 'acts-as-taggable-on', '~> 2.2.2'

# embed latest tweets
gem 'twitter'

# easier form building
gem 'simple_form'

# twitter bootstrap for Rails 3.x
# gem "twitter-bootstrap-rails"

# 3rd party authentication
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'

# gem for linkedin api
gem 'linkedin'

# talk to the YouTube API
gem 'youtube_it'

# handle money values
gem 'money-rails'

# exchange rates
gem 'google_currency'

# allows interaction with google docs in drive
gem 'google_drive'

# google analytics custom events
gem 'gabba'

# ruby http server
gem 'unicorn'

# required for caching in heroku
gem 'memcachier'
gem 'dalli'
gem 'cacheable_flash' # used to deal with flash messages when caching pages

# automatically create links within a body of text
gem 'rails_autolink'

group :development do
  gem 'heroku' #included for rake db:mirror system calls
  gem 'heroku_san'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'yui-compressor'
  gem 'jquery-ui-rails'
  gem 'sass-rails', '~> 3.2.6'
  gem 'asset_sync'
end

gem 'jquery-rails'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'ruby_gntp'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'cucumber-rails'
  gem 'jasmine'

  # guard prompt on osx
  platforms :ruby do
    gem 'rb-readline'
  end
end

group :test do
  gem "factory_girl_rails"
  gem 'launchy'
  # database_cleaner is necessary when database transactions are switched off,
  # in order to test js with selenium
  gem 'database_cleaner'
  gem 'spork', '~> 0.9.0.rc'
end
