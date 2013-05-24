EightyThousandHours::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # configure app to use Amazon S3 as an asset host
  config.action_controller.asset_host = "http://#{ENV['S3_BUCKET']}.s3.amazonaws.com"

  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true
  config.assets.css_compressor = :yui
  config.assets.js_compressor = :uglifier

  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = true

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  
  # outbound email config
  config.action_mailer.default_url_options = { :host => '80000hours.org' }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => ENV['SMTP_ADDRESS'],
    :port                 => ENV['SMTP_PORT'],
    :domain               => ENV['SMTP_DOMAIN'],
    :user_name            => ENV['SMTP_USERNAME'],
    :password             => ENV['SMTP_PASSWORD'],
    :authentication       => 'plain',
    :enable_starttls_auto => true  }
    
  config.middleware.use ExceptionNotifier,
      :email_prefix => "[Error at 80000hours.org] ",
      :sender_address => %{"noreply80000" <eighty.thousand@gmail.com>},
      :exception_recipients => %w{powermoveguru@gmail.com robbie.shade@gmail.com jeff.c.pole@gmail.com isaac.kaspar.lewis@gmail.com}

  PAPERCLIP_STORAGE_OPTIONS = {:storage => :s3, 
                               :s3_credentials => { :access_key_id     => ENV['S3_ACCESS'],
                                                    :secret_access_key => ENV['S3_SECRET'],
                                                    :bucket            => ENV['S3_BUCKET'] } }

  config.logger.level = 2 # Must be numeric here - 0 :debug, 1 :info, 2 :warn, 3 :error, and 4 :fatal
  # NOTE:   with 0 you're going to get all DB calls, etc.
end
