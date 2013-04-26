class SurveysController < ApplicationController
  
  def show
    @survey = Survey.find(params[:id])

    @url = @survey.get_url_for_user(current_user)
  end

  def new_member_survey
    if !user_signed_in?
      @error_type = "signup"
      render 'shared/display_error'
    end
  end

  def completed_new_member_survey
  	# save results in google spreadsheet
  	Survey.fill_members_survey(params, current_user)
  	redirect_to '/'
  end
end
