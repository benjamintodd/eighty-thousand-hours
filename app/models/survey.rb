class Survey < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged

  def get_url_for_user( user )
    url = self.url
    url += "&#{self.name_box}=#{user.name}"
    url += "&#{self.email_box}=#{user.email}"
    url += "&#{self.id_box}=#{user.id}"

    url
  end

  def self.fill_members_survey(params, user)
  	session = GoogleDrive.login("jeff.c.pole@gmail.com", "SHox2008")

  	# First worksheet of
  	# https://docs.google.com/spreadsheet/ccc?key=0AqjJhbNzdSRcdG5PbFBRZFk4OXNSb0hGTUc2T08yNUE#gid=0
  	ws = session.spreadsheet_by_key("0AqjJhbNzdSRcdG5PbFBRZFk4OXNSb0hGTUc2T08yNUE").worksheets[0]

  	new_row = ws.num_rows + 1

  	# enter data in columns
  	ws[new_row, 1] = Time.now.to_s
  	ws[new_row, 2] = user.name
  	ws[new_row, 3] = user.email

  	# 'how did you find out about 80000 hours'
  	discovered = []
  	discovered << "Recommended by a friend" if params[:discovered_friend]
  	discovered << "Online search" if params[:discovered_online]
    discovered << "Saw one of our blog posts on social media" if params[:discovered_blog]
    discovered << "Saw an article about us" if params[:discovered_article]
    discovered << "Attended an event" if params[:discovered_event]
    discovered << "Other" if params[:discovered_other]
  	ws[new_row, 4] = discovered.join("\n") if !discovered.empty?

  	ws[new_row, 5] = params[:discovered_comments] if params[:discovered_comments]
  	ws[new_row, 6] = params[:changed_ideas] if params[:changed_ideas]
  	# ws[new_row, 7] no longer used
  	ws[new_row, 8] = params[:changes] if params[:changes]
  	ws[new_row, 9] = params[:learning] if params[:learning]

  	# 'Why did you join 80,000 Hours?'
  	joined = []
  	joined << "To be able to chat to other members" if params[:joined_chat]
  	joined << "To find members who share your interests" if params[:joined_find]
    joined << "To show your support for our ideas and encourage more people to join" if params[:joined_support]
    joined << "To create an online profile, with extra site features" if params[:joined_profile]
    joined << "To gain better access to one-on-one careers advice" if params[:joined_advice]
    joined << "To help you stay true to your goals to make the world a better place" if params[:joined_goals]
    joined << "Other" if params[:joined_other]
  	ws[new_row, 10] = joined.join("\n") if !joined.empty?

  	ws[new_row, 11] = params[:joined_comments] if params[:joined_comments]
    ws[new_row, 12] = params[:age] if params[:age]
  	ws[new_row, 13] = params[:donation] if params[:donation]
  	ws[new_row, 14] = params[:donation_currency] if params[:donation_currency]
  	ws[new_row, 15] = params[:donation_counterfactual] if params[:donation_counterfactual]
  	ws[new_row, 16] = params[:donation_counterfactual_currency] if params[:donation_counterfactual_currency]
    ws[new_row, 17] = params[:donation_comments] if params[:donation_comments]

  	# 'Which organisations do you intend to donate to?'
  	organisations = []
  	organisations << "Givewell recommended charity" if params[:donate_givewell]
  	organisations << "Giving What We Can recommended charity" if params[:donate_gwwc]
    organisations << "Other charities working to help people in the developing world" if params[:donate_developing]
    organisations << "Political organisations" if params[:donate_political]
    organisations << "Charities working to help people in the developed world" if params[:donate_developed]
    organisations << "Effective Animal Activism recommended charity" if params[:donate_eaa]
    organisations << "Other animal charities" if params[:donate_animal]
    organisations << "Organisations trying to reduce the risk of global catastrophe" if params[:donate_xrisk]
    organisations << "Meta-charities (charities that evaluate other charities or causes)" if params[:donate_meta]
    organisations << "A fund to save for future donations" if params[:donate_future]
    organisations << "Other" if params[:donate_other]
  	ws[new_row, 18] = organisations.join("\n") if !organisations.empty?

  	# 'If you had not discovered the ideas of 80,000 Hours, which organisations would you have donated to?'
  	organisations = []
  	organisations << "Givewell recommended charity" if params[:donate_counterfactual_givewell]
  	organisations << "Giving What We Can recommended charity" if params[:donate_counterfactual_gwwc]
    organisations << "Other charities working to help people in the developing world" if params[:donate_counterfactual_developing]
    organisations << "Political organisations" if params[:donate_counterfactual_political]
    organisations << "Charities working to help people in the developed world" if params[:donate_counterfactual_developed]
    organisations << "Effective Animal Activism recommended charity" if params[:donate_counterfactual_eaa]
    organisations << "Other animal charities" if params[:donate_counterfactual_animal]
    organisations << "Organisations trying to reduce the risk of global catastrophe" if params[:donate_counterfactual_xrisk]
    organisations << "Meta-charities (charities that evaluate other charities or causes)" if params[:donate_counterfactual_meta]
    organisations << "A fund to save for future donations" if params[:donate_counterfactual_future]
    organisations << "Other" if params[:donate_counterfactual_other]
  	ws[new_row, 19] = organisations.join("\n") if !organisations.empty?

  	ws[new_row, 20] = params[:organisations_comments] if params[:organisations_comments]
  	ws[new_row, 21] = params[:improve_world] if params[:improve_world]
  	ws[new_row, 22] = params[:improve_world_comments] if params[:improve_world_comments]
  	ws[new_row, 23] = user.id

  	ws.save()

  	# store age in member info table
  	if params[:age]
      user.member_info.age = params[:age]
      user.member_info.save
  	end
  end
end
