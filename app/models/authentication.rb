class Authentication < ActiveRecord::Base
  belongs_to :user

  def self.process_omniauth_session(omniauth, user)
    if omniauth.provider == "facebook"
      user.avatar_from_url("http://graph.facebook.com/#{omniauth.uid}/picture?type=square&width=400&height=400") if !user.avatar || user.avatar.to_s.include?("avatar_default")
      user.external_facebook = omniauth['info']['urls']['Facebook'] if omniauth['info']['urls'] && omniauth['info']['urls']['Facebook']
      user.save
    elsif omniauth.provider == "google_oauth2"
      if !user.avatar || user.avatar.to_s.include?("avatar_default")
        if omniauth.info.image
          user.avatar_from_url(omniauth.info.image)
          user.save
        end
      end
    end
  end

  def self.process_facebook_info(omniauth, user)
  	# pull main info
    user.avatar_from_url("http://graph.facebook.com/#{omniauth.uid}/picture?type=square&width=400&height=400")
    user.location = omniauth.info.location.name if omniauth.info.location && omniauth.info.location.name
    #user.external_facebook = omniauth.extra.raw_info.link if omniauth.extra.raw_info.link
    user.external_facebook = omniauth['info']['urls']['Facebook'] if omniauth['info']['urls'] && omniauth['info']['urls']['Facebook']

    begin
      if omniauth.extra && omniauth.extra.raw_info
        # if other info present add to member_info table
        if user.member_info
          member_info = user.member_info
        else
          member_info = MemberInfo.new
          member_info.user_id = user.id
        end

        member_info.gender = omniauth.extra.raw_info.gender if omniauth.extra.raw_info.gender
        if positions = omniauth.extra.raw_info.work
          positions.each do |position|
            new_pos = Position.new
            new_pos.position = position.position.name if position.position.name
            new_pos.organisation = position.employer.name if position.employer && position.employer.name
            
            if position.start_date
              date = position.start_date.split("-")
              if date[0].to_s != "0000"
                new_pos.start_date_year = date[0].to_i
                new_pos.start_date_year = convert_month(date[1].to_i) if date[1]
              end
            end
            if position.end_date
              date = position.end_date.split("-")
              if date[0].to_s != "0000"
                new_pos.end_date_year = date[0].to_i
                new_pos.end_date_month = convert_month(date[1].to_i) if date[1]
              end
            end
            
            new_pos.member_info = member_info
            new_pos.save
          end
        end
        if educations = omniauth.extra.raw_info.education
          educations.each do |education|
            new_ed = Education.new
            new_ed.university = education.school.name if education.school && education.school.name
            new_ed.end_date_year = education.year.name.to_i if education.year && education.year.name
            new_ed.member_info = member_info
            new_ed.save
          end
        end
      end
    rescue => e
      p e.message
    ensure
      member_info.save if member_info
      user.save
    end
  end

  private
  def self.convert_month(num)
    months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    return months[num.to_i]
  end
end
