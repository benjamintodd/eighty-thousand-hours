#TODO Is this now defunct?

class ChatRequestMailer < ActionMailer::Base
  default :from => "admin@80000hours.org"
 
  def chat_request_email(name,email,phone,skype,options)
    @name = name
    @email = email
    @phone = phone
    @skype = skype
    @options = options
    mail(:to => "info@80000hours.org",
         :subject => "[ChatToUs] #{name}",
         :template_path => 'chat_requests',
         :template_name => 'chat_request_email',
         :reply_to => email)
  end
end
