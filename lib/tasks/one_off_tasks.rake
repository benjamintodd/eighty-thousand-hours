desc "Calculates profile completeness score for each member profile"
task :update_profile_completeness_scores => :environment do
  puts "Updating profile completeness score for all members"
  EtkhProfile.all.each do |profile|
    profile.completeness_score = profile.get_profile_completeness
    profile.save
  end
  puts "done."
end

desc 'One-off task to fix personal website bug'
task :fix_personal_website_bug => :environment do 
  puts "Starting..."
  User.all.each do |user|
    if user.external_website
      if user.external_website && !user.external_website.empty? && user.external_website[0..6] != "http://" && user.external_website[0..7] != "https://"
        new_address = "http://" + user.external_website
        user.update_attributes(external_website: new_address)
      end
    end
  end
  puts "Done."
end

task :mail_users_avatars => :environment do
  puts "Identifying deleted avatars"
  User.all.each do |user|
    if user.avatar && !user.avatar.to_s.include?("avatar_default")
      UserMailer.avatar_deleted_email(user).deliver! if !User.active_link?(user.avatar.to_s)
      puts "Emailing: #{user.slug}"
    end
  end
  puts "done."
end