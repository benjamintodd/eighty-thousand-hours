task :after_deploy do
	HerokuSan.project.each_app do |stage|
		puts "--> Precompiling assets & uploading to the asset host"
		system("heroku run rake assets:precompile --app #{stage.app}")
	end
end