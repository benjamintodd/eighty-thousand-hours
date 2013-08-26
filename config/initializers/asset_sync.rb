# Since this gem is only loaded with the assets group, we have to check to 
# see if it's defined before configuring it.
if defined?(AssetSync)
  AssetSync.configure do |config|
    config.fog_provider = 'AWS'
    config.fog_region = 'eu-west-1'
    config.aws_access_key_id = ENV['S3_ACCESS']
    config.aws_secret_access_key = ENV['S3_SECRET']
    config.fog_directory = ENV['S3_BUCKET']

    # Fail silently.  Useful for environments such as Heroku
    config.fail_silently = false
  end
end
