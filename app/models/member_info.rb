# contains table of information about members. 
# This information is separate from the member profile which is about public information.
# This is priate information that may be used for impact tracking
class MemberInfo < ActiveRecord::Base
  belongs_to :user
  attr_accessible :DOB
end