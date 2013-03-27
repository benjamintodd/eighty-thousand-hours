require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require 'csv'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module EightyThousandHours
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'en'
    config.i18n.locale = :'en'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    # devise instructions said maybe want to do this for Rails 3.1 on Heroku...
    config.assets.initialize_on_precompile = false

    # must explicitly precompile all JS and CSS except application.js/css
    config.assets.precompile += %w[active_admin.js all-members-page.js application-form.js authentications.js.coffee comments.js donation-calculator.js donations.js.coffee edit-profile.js education-form.js faq_toggle.js linkedin-form.js members-page.js misc.js position-form.js profile-popup.js profiles-selection.js search-form.js view-profile.js bootstrap-datepicker.js bootstrap-progressbar.js google-analytics.js highcharts.js html5.js jquery.hoverIntent.minified.js jquery.pageless.js jquery.reveal.js]
    config.assets.precompile += %w[active_admin.css]

    # serve up our own custom fonts
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    # caching in heroku
    config.cache_store = :dalli_store
    
    # generators
    config.generators do |g|
      # g.stylesheets         false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    # needed for logging to work under unicorn
    config.logger = Logger.new(STDOUT)
  end
end
