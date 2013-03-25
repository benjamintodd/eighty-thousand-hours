# class stores all the metrics calculated on a monthly basis
class MonthlyMetric < ActiveRecord::Base
  def self.to_csv
    columns = ["date", "average overall profile completeness", "donation declaration opt-in", "median donation declaration percentage", "users with avatars percentage", "new users with avatars percentage"]
    CSV.generate do |csv|
      csv << columns
      self.all.each do |month|
        entries = [month.date.to_date.to_s, month.average_profile_completeness, month.donation_optin_percentage, month.median_donation_percentage, month.avatar_percentage, month.avatar_percentage_new_users]
        csv << entries
      end
    end
  end
end