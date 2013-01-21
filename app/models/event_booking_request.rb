class EventBookingRequest
	include ActiveModel::Validations

	validates_presence_of :name, :email, :amf_donation

	#to work with form there must be an id attribute
	attr_accessor :id, :name, :email, :current_role, :desired_information, :amf_donation, :mailing_list

	#override save method
	def save
		if self.valid?
			EventBookingRequestMailer.event_booking_request_email(name,email,current_role,desired_information,amf_donation,mailing_list)
			return true
		else
			return false
		end
	end

	#in order to validate attributes later the attributes must be initialised
	def initialize(attributes = {})
		attributes.each do |key, value|
			self.send("#{key}=", value)
		end
		@attributes = attributes
	end

	#used to validate attributes after submitting form
	def read_attribute_for_validation(key)
	    @attributes[key]
    end

	#used by form
	def to_key
	end

	#record is not stored and disappears after creation
	def persisted?
		false
	end
end