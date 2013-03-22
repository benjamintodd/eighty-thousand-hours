# class stores all the metrics calculated on a weekly basis
class WeeklyMetric < ActiveRecord::Base
  def self.to_csv
    columns = ["date", "average overall profile completeness", "donation declaration opt-in", "median donation delcaration percentage"]
    CSV.generate do |csv|
      csv << columns
      self.all.each do |week|
        entries = [week.date.to_date.to_s, week.average_profile_completeness, week.donation_optin_percentage, week.median_donation_percentage]
        csv << entries
      end
    end
  end
end