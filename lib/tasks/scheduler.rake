desc "This task is called by the Heroku scheduler add-on"
task :update_facebook_likes => :environment do
  puts "Updating Facebook like counts for posts..."
  BlogPost.update_facebook_likes
  puts "done."
end

desc 'Calculates a set of metrics on a weekly basis'
task :calculate_weekly_metrics => :environment do
  if Time.now.friday?
    puts "Calculating weekly metrics..."
    WeeklyMetric.calculate
    puts "done."
  end
end

desc 'Calculates a set of metrics on a monthly basis'
task :calculate_monthly_metrics => :environment do
  previous = MonthlyMetric.last
  days_since_previous = (Time.now - previous.date) / 60 / 60 / 24 if previous
  if Time.now.friday? && previous && days_since_previous >= 27
    puts "Calculating monthly metrics..."
    MonthlyMetric.calculate
    puts "done."
  end
end