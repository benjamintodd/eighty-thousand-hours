class EventBookingRequestMailer < ActionMailer::Base
	default :from => "admin@80000hours.org"
	
	def event_booking_request_email(name,email,current_role,desired_information,amf_donation,mailing_list)
		@name = name
		@email = email
		@current_role = current_role
		@desired_information = desired_information
		@amf_donation = amf_donation
		@mailing_list = mailing_list
		
		#mail(:to => "abigail.v.taylor@gmail.com",
	    mail(:to => "jeff.c.pole@gmail.com",
	         :subject => "[Healthcare event booking] #{name}",
	         :reply_to => @email,
	         :template_path => 'event_booking_requests',
	         :template_name => 'event_booking_request_email')
	end
end