# contains details of individual education for educations list in members profile
class Education < ActiveRecord::Base
  belongs_to :etkh_profile
  belongs_to :member_info

  attr_accessible :university, 
        				  :course, 
        				  :qualification, 
        				  :start_date_year,
        				  :end_date_year,
        				  :current_education

  # if saved in etkh_profile also store education in member info table if it exists
  before_save do |education|
    if education.etkh_profile
      if education.etkh_profile.user.member_info
        member_info = education.etkh_profile.user.member_info
      else
        member_info = MemberInfo.new
        member_info.user_id = education.etkh_profile.user.id
        member_info.save
      end

      # store if education doesn't already exist in member info table
      member_info.educations.each do |e|
        if e.university == education.university
          # already exists
          return
        end
      end
      education.member_info_id = member_info.id
    end
   end

   # don't destroy if it belongs to etkh_profile or member_info
   before_destroy do |education|
    if education.etkh_profile_id != nil || education.member_info_id != nil
      errors.add :base, "Must set both etkh_profile_id and member_info_id to nil before education can be destroyed"
      return false
    end
   end
end