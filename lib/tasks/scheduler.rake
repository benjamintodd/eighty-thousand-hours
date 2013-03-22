desc "This task is called by the Heroku scheduler add-on"
task :update_facebook_likes => :environment do
  puts "Updating Facebook like counts for posts..."
  BlogPost.update_facebook_likes
  puts "done."
end

desc 'Calculates a set of metrics on a weekly basis'
task :calculate_weekly_metrics => :environment do
  puts "Calculating weekly metrics..."

  previous = WeeklyMetric.last
  last_week_date = previous ? previous.date : Time.now.advance(hours: -168)

  puts "Calculating average profile completeness score for all profiles"
  completeness = EtkhProfile.calculate_average_profile_completeness

  puts "Calculating percentage of users who opted in to donation declaration this week"
  optin = EtkhProfile.calculate_donation_optin_percentage(last_week_date)

  puts "Calculating median donation percentage value for users donation declaration"
  median = EtkhProfile.calculate_median_donation_percentage(last_week_date)

  week = WeeklyMetric.new
  week.average_profile_completeness = completeness
  week.median_donation_percentage = median
  week.donation_optin_percentage = optin
  week.date = Time.now
  week.save

  puts "done."
end