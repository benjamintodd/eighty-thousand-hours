class CareerAdviceRequestMailer < ActionMailer::Base
  default :from => "admin@80000hours.org"
 
  def career_advice_request_email(name,email,skype,background,thoughts,questions,mailing_list,uploaded_cv)
    @name = name
    @email = email
    @skype = skype
    @background = background
    @thoughts = thoughts
    @questions = questions
    @mailing_list = mailing_list
    if uploaded_cv
      attachments[uploaded_cv.original_filename] =  {
         :content=>uploaded_cv.read, 
         :mime_type=>uploaded_cv.content_type
      }
    end
    mail(:to => "careers@80000hours.org",
         :subject => "[Career advice request] #{name}",
         :reply_to => @email,
         :template_path => 'career_advice_requests',
         :template_name => 'career_advice_request_email')
  end
end
