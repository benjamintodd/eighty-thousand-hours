# contains table of information about members. 
# This information is separate from the member profile which is about public information.
# This is priate information that may be used for impact tracking
class MemberInfo < ActiveRecord::Base
  belongs_to :user
  has_many :positions
  has_many :educations

  attr_accessible :DOB, :age_updated_at

  # can't simply destroy positions
  before_destroy do |info|
    # remove member_info from the position and it will be destroyed if it does not also belong to an etkh_profile
  	info.positions.each do |position|
  		position.member_info_id = nil
      position.save
      position.destroy
  	end

    # same for educations
    info.educations.each do |education|
      education.member_info_id = nil
      education.save
      education.destroy
    end
  end

  before_save do |info|
    if info.DOB_changed?
      info.age = get_age_from_dob(info.DOB)
      info.age_updated_at = Time.now
    elsif info.age_changed?
      info.age_updated_at = Time.now
    end
    return true
  end

  def get_age
    if self.DOB
      self.age = get_age_from_dob(self.DOB)
      self.save
    end
    return self.age
  end

  private
  def get_age_from_dob(dob)
    now = Time.now.utc.to_date
    age = now.year - dob.year - (dob.to_date.change(:year => now.year) > now ? 1 : 0)
    return age
  end
end