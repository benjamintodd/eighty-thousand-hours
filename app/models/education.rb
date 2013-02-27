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
end