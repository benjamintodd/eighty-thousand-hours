desc "Calculates profile completeness score for each member profile"
task :update_profile_completeness_scores => :environment do
  puts "Updating profile completeness score for all members"
  EtkhProfile.all.each do |profile|
    profile.completeness_score = profile.get_profile_completeness
    profile.save
  end
  puts "done."
end