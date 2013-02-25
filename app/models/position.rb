# contains individual positions under experience in members profile
class Position < ActiveRecord::Base
  belongs_to :etkh_profile
  attr_accessible :position,
  				  :organisation,
  				  :start_date_month,
  				  :start_date_year,
  				  :end_date_month,
  				  :end_date_year
end