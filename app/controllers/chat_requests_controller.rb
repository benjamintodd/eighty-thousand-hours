class ChatRequestsController < ApplicationController
  def new
    @chat_request = ChatRequest.new
  end

  def create
    @chat_request = ChatRequest.new(params[:chat_request])
    if @chat_request.save
      flash[:"alert-success"] = "Thanks! We've received your contact details and we'll be in touch soon!"
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
