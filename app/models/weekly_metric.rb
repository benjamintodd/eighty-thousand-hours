# class stores all the metrics calculated on a weekly basis
class WeeklyMetric < ActiveRecord::Base
  def self.to_csv
    columns = ["date", "average overall profile completeness", "donation declaration opt-in", "median donation declaration percentage", "users with avatars percentage", "new users with avatars percentage"]
    CSV.generate do |csv|
      csv << columns
      self.all.each do |week|
        entries = [week.date.to_date.to_s, week.average_profile_completeness, week.donation_optin_percentage, week.median_donation_percentage, week.avatar_percentage, week.avatar_percentage_new_users]
        csv << entries
      end
    end
  end

  def self.calculate
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
  end
end