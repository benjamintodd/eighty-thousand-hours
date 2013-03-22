require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  def authorize_admin!
    authenticate_user!
    raise CanCan::AccessDenied unless can? :access, :admin
  end

  def after_sign_in_path_for(resource)
    if current_user.sign_in_count <= 1
      #assume the user has just signed up so redirect to edit profile
      edit_user_etkh_profile_path(current_user, current_user.etkh_profile)
    else
      #assume user is simply logging in and treat as normal
      if session[:user_return_to] == root_path
        dashboard_path
      else
        session[:user_return_to] || root_path
      end
    end
  end

  def after_sign_out_path_for(resource)
    #redirect to previous path
    request.referrer
  end
end
