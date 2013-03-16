class UsersController < ApplicationController
  load_and_authorize_resource :only => [:edit,:update,:destroy]

  def karma_test
    @users = User.all
  end

  def generate_users_test
    @selection_list = User.generate_users_list(10)
  end

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
    @donations = @user.donations.confirmed

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
      # deliver message to user
      sender = current_user
      recipient = User.find(params[:user_id])
      subject = params[:subject]
      body = params[:body]
      UserMailer.contact_user(sender, recipient, subject, body).deliver!
    end
    render nothing: true
  end

  def initalise_contact_user
    if user_signed_in?
      @user_id = params[:user_id]

      # javascript to show popup
      render 'users/initialise_contact_user'
    else
      if request.xhr?
        render 'shared/sign_up_modal'
      else
        @error_type = "signup"
        render 'shared/display_error'
      end
    end
  end
end
