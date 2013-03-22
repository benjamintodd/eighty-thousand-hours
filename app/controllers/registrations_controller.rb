class RegistrationsController < Devise::RegistrationsController
  def new
    session[:user_return_to] ||= request.referer
    super
  end

  def create
    # Log this in Google Analytics
    Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "Created via email/password", params[:user][:name], params[:user][:email])
    super
  end

  def update
    # if user signed up through omniauth then they
    # don't need to provide a password when updating details

    #update email notification settings
    @user = User.find(current_user.id)
    @user.notifications_on_forum_posts = params[:new_notifications_on_forum_posts]
    @user.notifications_on_comments = params[:new_notifications_on_comments]
    @user.save

    #update other details
    if current_user.omniauth_signup      
      if @user.update_attributes(params[:user])
        @user.skip_confirmation!
        flash[:"alert-success"] = "Updated your account details"
        redirect_to edit_registration_path @user
      else
        super
      end
    else
      super
    end
  end
end
