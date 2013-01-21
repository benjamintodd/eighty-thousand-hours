class CareerAdviceRequestsController < ApplicationController
  def new
    @career_advice_request = CareerAdviceRequest.new
  end

  def create
    @career_advice_request = CareerAdviceRequest.new(params[:career_advice_request])
    if @career_advice_request.save
      flash[:"alert-success"] = "Thanks! We've received your information and we'll be in touch soon!"
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
