namespace :db do
  def local_db
    config_file = File.join Rails.root, 'config', 'database.yml'
    doc = YAML::load_file(config_file)
    doc[Rails.env]['database']
  end

  desc 'Copies production db into local development db'
  app = "eighty-thousand-hours"
  task :mirror do
    system(%Q{
      heroku pgbackups:capture --expire HEROKU_POSTGRESQL_ONYX_URL --app #{app} && \
      curl -o /tmp/hic-db.dump $(heroku pgbackups:url --app #{app}) && \
      pg_restore --verbose --clean --no-acl --no-owner -d #{local_db} /tmp/hic-db.dump
    })
  end

  desc 'Copies live site db to dev site db'
  mainapp = "eighty-thousand-hours"
  devapp = "eighty-thousand-hours-new-dev"
  task :mirror_to_dev_site do
    system(%Q{
      heroku pgbackups:capture --expire HEROKU_POSTGRESQL_ONYX_URL --app #{mainapp}
      heroku pgbackups:restore DATABASE $(heroku pgbackups:url --app #{mainapp}) --app #{devapp}
    })
  end

  desc 'Print the current database migration version number'
  task :version => :environment do
    puts ActiveRecord::Migrator.current_version
  end
end
