# contains table of information about members. 
# This information is separate from the member profile which is about public information.
# This is priate information that may be used for impact tracking
class MemberInfo < ActiveRecord::Base
  belongs_to :user
  has_many :positions
  has_many :educations

  attr_accessible :DOB

  # can't simply destroy positions
  before_destroy do |info|
    # remove member_info from the position and it will be destroyed if it does not also belong to an etkh_profile
  	info.positions.each do |position|
  		position.member_info_id = nil
      position.save
      position.destroy
  	end
  end
end