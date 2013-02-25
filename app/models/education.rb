# contains details of individual education for educations list in members profile
class Education < ActiveRecord::Base
  belongs_to :etkh_profile
  attr_accessible :university, :course, :qualification, :start_date, :end_date
end