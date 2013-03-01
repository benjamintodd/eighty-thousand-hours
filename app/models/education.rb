# contains details of individual education for educations list in members profile
class Education < ActiveRecord::Base
  belongs_to :etkh_profile
  attr_accessible :university, 
  				  :course, 
  				  :qualification, 
  				  :start_date_month,
  				  :start_date_year,
  				  :end_date_month,
  				  :end_date_year,
  				  :current_education

  # gives a score for the month. Used in comparison of months in sorting algorithm
  def order_month
    return 0 if !self.end_date_month || self.end_date_month == ""
    return 1 if self.end_date_month == "January"
    return 2 if self.end_date_month == "February"
    return 3 if self.end_date_month == "March"
    return 4 if self.end_date_month == "April"
    return 5 if self.end_date_month == "May"
    return 6 if self.end_date_month == "June"
    return 7 if self.end_date_month == "July"
    return 8 if self.end_date_month == "August"
    return 9 if self.end_date_month == "September"
    return 10 if self.end_date_month == "October"
    return 11 if self.end_date_month == "November"
    return 12 if self.end_date_month == "December"
  end
end