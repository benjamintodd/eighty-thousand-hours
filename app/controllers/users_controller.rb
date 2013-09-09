class UsersController < ApplicationController
  load_and_authorize_resource :only => [:edit,:update,:destroy]

  def merge
    if session[:omniauth]
      # want the user to be redirected to account edit page on sign-in
      session[:user_return_to] = edit_registration_path :user
      render 'merge'
    else
      redirect_to new_user_registration_path
    end
  end

  def user_activity
    @user = User.find_by_id(params[:id])
    if params[:activity_type]
      @activity_type = params[:activity_type]
    else
      @activity_type = "BlogPosts"
    end
  end

  def index
    @users = User.all
    
    respond_to do |format|
      format.html
      format.csv { send_data User.to_csv }
    end
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name

    @menu_root = "Our community"
    @menu_current = "Our members"
  end

  def destroy
    user = User.find( params[:id] )
    name = user.name
    if user.destroy
      flash[:"alert-success"] = "Deleted #{name}"
    else
      flash[:"alert-error"] = "Failed to delete #{name}!"
    end
    redirect_to users_path
  end

  def remove_avatar
    user = User.find(params[:id])
    if user.avatar.destroy
      render 'etkh_profiles/remove_avatar'
    else
      render nothing: true
    end
    user.avatar = nil
    user.avatar_remote_url = nil
    user.save
    user.etkh_profile.get_profile_completeness
  end

  def edit
    @user = current_user
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:"alert-success"] = "Your profile was successfully updated"
      redirect_to(current_user)
    else
      render :action => "edit"
    end
  end

  def email_list
    @members = User.etkh_members
    @non_members = User.non_etkh_members

    authorize! :read, User
  end

  def contact_user
    if params[:commit] != "Cancel"
      # check captcha
      answer = Captchas[params[:captcha_question]]

      if answer.downcase != params[:captcha_answer].downcase
        @user_id = params[:user_id]
        @captcha = Captchas.keys.sample

        # TODO: display error message here
      else
        # deliver message to user
        sender = current_user
        recipient = User.find(params[:user_id])
        subject = params[:subject]
        body = params[:body]
        UserMailer.contact_user(sender, recipient, subject, body).deliver!

        #log event in google analytics
        Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "User contacted by other user", nil, recipient.id)
      end
    end
    render nothing: true
  end

  Captchas = {
    "Which is larger, 1 or 2?" => "2",
    "Which is larger, 1 or 4?" => "4",
    "Which is larger, 7 or 1?" => "7",
    "Which is larger, 2 or 3?" => "3",
    "Which is larger, 3 or 6?" => "6",
    "Which is larger, 9 or 3?" => "9",
    "Which is larger, 4 or 2?" => "4",
    "Which is larger, 5 or 8?" => "8",
    "The sky is blue. What colour is the sky?" => "blue",
    "Grass is green. What colour is grass?" => "green",
    "Tomatoes are red. What colour are tomatoes?" => "red",
    "What is 1 plus 1?" => "2",
    "What is 2 plus 3?" => "5",
    "What is 3 plus 1?" => "4",
    "What is 3 plus 3?" => "6",
    "What is 2 plus 5?" => "7"
  }

  def initalise_contact_user
    if user_signed_in?
      @user_id = params[:user_id]

      @captcha = Captchas.keys.sample

      # javascript to show popup
      render 'users/initialise_contact_user'
    else
      if request.xhr?
        render 'shared/error_modal', locals: { error_type: "signup", error_message: ""}
      else
        render 'shared/display_error', locals: { error_type: "signup", error_message: ""}
      end
    end
  end

  def initialise_invite_linkedin_connection
    if user_signed_in?
      # redirect_to {controller: 'authentications', action: 'linkedin_invite_connection', email: user.linkedin_email, user_id: user.id}
      redirect_to "/authentications/linkedin_invite_connection?email=#{params[:email]}&user_id=#{params[:user_id]}"
    else
      @error_type = "signup"
      if request.xhr?
        render 'shared/error_modal'
      else
        render 'shared/display_error'
      end
    end
  end
end
