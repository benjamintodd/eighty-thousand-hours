desc 'One-off task to fix personal website bug'
task :fix_personal_website_bug => :environment do 
  User.all.each do |user|
    if user.external_website
      if user.external_website[0..6] != "http://"
        new_address = "http://" + user.external_website
        user.update_attributes(external_website: new_address)
      end
    end
  end
end