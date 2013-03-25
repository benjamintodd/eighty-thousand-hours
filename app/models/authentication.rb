class Authentication < ActiveRecord::Base
  belongs_to :user

  def self.process_facebook_info(omniauth, user)
  	# pull main info
    user.avatar_from_url("http://graph.facebook.com/#{omniauth.uid}/picture?type=square&width=400&height=400")
    user.location = omniauth.info.location.name if omniauth.info.location.name
    user.external_facebook = omniauth.urls.Facebook if omniauth.urls.Facebook

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
        new_pos.organisation = position.employer.name if position.employer.name
        
        if position.start_date
          date = position.start_date.split("-")
          if date.length == 1
            new_pos.start_date_year = DateTime.new(date[0].to_i)
          elsif date.length == 2
            new_pos.start_date_year = DateTime.new(date[0].to_i, date[1].to_i)
          elsif date.length == 3
            new_pos.start_date_year = DateTime.new(date[0].to_i, date[1].to_i, date[2].to_i)
          end
        end
        if position.end_date
          date = position.end_date.split("-")
          if date.length == 1
            new_pos.end_date_year = DateTime.new(date[0].to_i)
          elsif date.length == 2
            new_pos.end_date_year = DateTime.new(date[0].to_i, date[1].to_i)
          elsif date.length == 3
            new_pos.end_date_year = DateTime.new(date[0].to_i, date[1].to_i, date[2].to_i)
          end
        end
        
        new_pos.member_info = member_info
        new_pos.save
      end
    end
    if educations = omniauth.extra.raw_info.education
      educations.each do |education|
        new_ed = Education.new
        new_ed.university = education.school.name if education.school.name
        new_ed.end_date_year = DateTime.new(education.year.name.to_i) if education.year.name
        new_ed.member_info = member_info
        new_ed.save
      end
    end
    member_info.save
    user.save
  end
end
