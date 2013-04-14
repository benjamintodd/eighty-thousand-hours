# class stores all the metrics calculated on a monthly basis
class MonthlyMetric < ActiveRecord::Base
  def self.to_csv
    columns = ["date", "average overall profile completeness", "donation declaration opt-in", "median donation declaration percentage", "users with avatars percentage", "new users with avatars percentage", "number of users who tracked donations", "total donations tracked(USD)"]
    CSV.generate do |csv|
      csv << columns
      self.all.each do |month|
        entries = [month.date.to_date.to_s, month.average_profile_completeness, month.donation_optin_percentage, month.median_donation_percentage, month.avatar_percentage, month.avatar_percentage_new_users, month.number_users_tracking_donations, month.total_donations]
        csv << entries
      end
    end
  end

  def self.calculate
    previous = MonthlyMetric.last
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
  end
end