class UserMailer < ActionMailer::Base
  default from: "admin@80000hours.org"

  def welcome_email(user)
    @name = user.first_name
    mail to: user.email, subject: "[80,000 Hours] New account"
  end

  def contact_user(sender, recipient, subject, body)
  	# get the name of user sending the message
  	@contact_name = sender.name

  	# get the email of the user sending the message
  	@contact_email = sender.email

  	# get the subject and body of the message
  	@subject = subject
  	@body = body

  	mail(to: recipient.email, \
  		subject: "[80,000 Hours] You have been contacted by another member")
  end

  def avatar_deleted_email(user)
    @name = user.first_name
    @profile_path = edit_user_etkh_profile_path(user, user.etkh_profile)
    mail(to: user.email, subject: "[80,000 Hours] Problem with your avatar")
  end
end
