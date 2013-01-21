class EventBookingRequestsController < ApplicationController
	def new
		#create instance variable for use on the form
		@event_booking_request = EventBookingRequest.new
	end

	def create
		@event_booking_request = EventBookingRequest.new(params[:event_booking_request])
		if @event_booking_request.save
			flash[:"alert-success"] = "Thanks! We've received your booking request and will be in touch soon"
			if user_signed_in?
				redirect_to dashboard_path
			else
				redirect_to root_path
			end
		else
			render 'new'
		end
	end
end