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

    previous = WeeklyMetric.last
    last_week_date = previous ? previous.date : Time.now.advance(hours: -168)

    completeness = EtkhProfile.calculate_average_profile_completeness
    optin = EtkhProfile.calculate_donation_optin_percentage(last_week_date)
    median = EtkhProfile.calculate_median_donation_percentage(last_week_date)
    overall_avatar_percentage = User.calculate_avatar_percentage
    new_users_avatar_percentage = User.calculate_avatar_percentage(last_week_date)

    week = WeeklyMetric.new
    week.average_profile_completeness = completeness
    week.median_donation_percentage = median
    week.donation_optin_percentage = optin
    week.avatar_percentage = overall_avatar_percentage
    week.avatar_percentage_new_users = new_users_avatar_percentage
    week.date = Time.now
    week.save

    puts "done."
  end
end

desc 'Calculates a set of metrics on a monthly basis'
task :calculate_monthly_metrics => :environment do
  previous = MonthlyMetric.last
  days_since_previous = (Time.now - previous.date) / 60 / 60 / 24 if previous
  if Time.now.friday? && previous && days_since_previous >= 27
    puts "Calculating monthly metrics..."
    
    last_month_date = previous ? previous.date : Time.now.advance(months: -1)

    completeness = EtkhProfile.calculate_average_profile_completeness
    optin = EtkhProfile.calculate_donation_optin_percentage(last_month_date)
    median = EtkhProfile.calculate_median_donation_percentage(last_month_date)
    overall_avatar_percentage = User.calculate_avatar_percentage
    new_users_avatar_percentage = User.calculate_avatar_percentage(last_month_date)

    number_users_donations = Donation.number_of_users_donate_since_date(last_month_date)
    total_donations = Donation.total_donations_since_date(last_month_date)

    month = MonthlyMetric.new
    month.average_profile_completeness = completeness
    month.median_donation_percentage = median
    month.donation_optin_percentage = optin
    month.avatar_percentage = overall_avatar_percentage
    month.avatar_percentage_new_users = new_users_avatar_percentage
    month.number_users_tracking_donations = number_users_donations
    month.total_donations = total_donations
    month.date = Time.now
    month.save

    puts "done."
  end
end