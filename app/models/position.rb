# contains individual positions under experience in members profile
class Position < ActiveRecord::Base
  belongs_to :etkh_profile
  attr_accessible :position, :organisation, :start_date, :end_date
end