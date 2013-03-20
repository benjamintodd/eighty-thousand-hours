LIST_LENGTH = 10
class EtkhProfilesController < ApplicationController
  load_and_authorize_resource :only => [:new,:create,:edit,:update,:destroy]

  def new     #this is not triggered when a new member signs up
    if current_user.nil?
      raise CanCan::AccessDenied.new("You need to create an account first!", :create, EtkhProfile)
    end

    if current_user.etkh_profile.nil?
      # create a new profile for the user
      @etkh_profile = EtkhProfile.new
      current_user.etkh_profile = @etkh_profile

      # fire off an email informing 80k team (join@80k..)
      EtkhProfileMailer.tell_team(current_user).deliver!

      # send an email to the user
      EtkhProfileMailer.thank_applicant(current_user).deliver!

      # add name to 'show your support'
      @supporter = Supporter.new(:name => current_user.name, :email => current_user.email)
      @supporter.save

      redirect_to members_survey_path
    else
      # user already has a profile but has visited /members/new
      render 'edit'
    end
    @menu_root = "Membership"
    @menu_current = "Join now"
  end

  def index
    get_grouped_profiles

    @title = "Members"
  end

  def get_grouped_profiles
    @profiles = EtkhProfile.all.to_a.sort_by{|p| p.user.name[0].upcase }
    @grouped_profiles = @profiles.group_by{ |profile| profile.user.name[0].upcase }
    @newest_profiles = EtkhProfile.newest.limit(8)
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
    @donations = @user.donations.confirmed
    @profile = @user.etkh_profile

    if !@profile.public_profile && !current_user
      @error_type = "signup"
      @error_message = "This member's profile is private."
      if request.xhr?
        render 'shared/sign_up_modal'
      else
        render 'shared/display_error'
      end
    end

    @menu_root = "Our community"
    @menu_current = "Our members"
  end

  def destroy
    profile = EtkhProfiles.find( params[:id] )
    if profile.destroy
      flash[:"alert-success"] = "Deleted profile"
    else
      flash[:"alert-error"] = "Failed to delete profile!"
    end
    redirect_to users_path
  end

  def edit
    @etkh_profile = current_user.etkh_profile

    # indicate whether profile is being created for first time or not
    @new_profile = session[:new_profile] == "true" ? true : false
    session[:new_profile] = nil

    # indicate whether user has signedup with linkedin or not
    @linkedin_signup = current_user.linkedin_email ? true : false

    if @new_profile == true 
      flash[:"alert-success"] = "Account successfully created."
    end
  end

  def update
    if params[:user][:external_website][0..6] != "http://"
      params[:user][:external_website] = "http://" + params[:user][:external_website]
    end

    if current_user.update_attributes(params[:user])
      flash[:"alert-success"] = "Your profile was successfully updated."

      # also update profile completeness score
      if current_user.etkh_profile
        current_user.etkh_profile.get_profile_completeness
      end
      
      #work out time since user profile was first created
      timediff = Time.now - current_user.confirmed_at   #in seconds
      timediff = timediff / 60  #in minutes

      #if much time has elapsed since the profile was created
      maxTime = 60 #minutes
      if timediff > maxTime
        #assume the user is editing their profile
        redirect_to( etkh_profile_path( current_user ) )
      else
        #assume the user is creating their profile for the first time
        redirect_to( members_survey_path )
      end
    else
      render :action => "edit"
    end
  end

  def show_linkedin_popup
    @linkedin_signup = params[:linkedin_signup] == "true" ? true : false
    render 'etkh_profiles/show_linkedin_popup'
  end

  def search
    # perform searching in model
    search_params = {name: params[:name], location: params[:location], organisation: params[:organisation], industry: params[:industry], position: params[:position], cause: params[:cause]}
    results = User.search(search_params)

    # order results by profile completeness
    results = User.sort_by_profile_completeness(results)

    # store results in session data as user ids
    session[:search_results] = []
    results.each do |user|
      session[:search_results] << user.id
    end

    # display first entries
    @selection = results.first(LIST_LENGTH)

    # create pointer to indicate which results are already displayed
    session[:search_results_pointer] = LIST_LENGTH

    session[:search] = true
    render 'etkh_profiles/search'
  end

  def our_members
    # displays list of members within community page

    # set up navbar
    @menu_root = "Our community"
    @menu_current = "Our members"
    @title = "Members"

    # determine whether this is a redirect from a search form on a different page
    # if the search form is submitted on a page other than the members page then it redirects here to display the results
    if params[:search] == "true"
      # fill out search form with values from other search form
      @name = params[:name]
      @location = params[:location]
      @organisation = params[:organisation]
      @industry = params[:industry]
      @position = params[:position]

      # notify JS to submit form
      @redirect_to_search = true
      if !@location.empty? || !@organisation.empty? || !@industry.empty? || !@position.empty?
        @advanced_search = true
      else
        @advanced_search = false
      end
    else
      ## get list of users to be displayed
      # generate users using algorithm
      @selected_users = EtkhProfile.generate_users(LIST_LENGTH,[current_user])

      # store newly selected users in session variable
      session[:selected_users] = []
      @selected_users.each do |user|
        session[:selected_users] << user.id
      end

      # indicate that this is not displaying search results
      session[:search] = false
    end
  end

  def get_more_members
    ## get list of users to be displayed

    # different courses of action whether displaying search results or random users
    if session[:search] == true
      # check if come to end of results
      if session[:search_results_pointer] < session[:search_results].length
        ## get next set of results
        @next_selection = []

        # get next batch of length list_length of results unless end is within next batch
        if session[:search_results_pointer]+LIST_LENGTH >= session[:search_results].length
          endpoint = session[:search_results].length
        else
          endpoint = session[:search_results_pointer]+LIST_LENGTH 
        end

        for i in session[:search_results_pointer]..(endpoint - 1)
          @next_selection << User.find_by_id(session[:search_results][i])
        end

        # update position of pointer
        session[:search_results_pointer] += LIST_LENGTH
      end
    else

      # get already selected users from session data
      if session[:selected_users]
        @selected_users = []
        session[:selected_users].each do |user_id|
          @selected_users << User.find_by_id(user_id)
        end
      end

      # generate more users using algorithm
      if @selected_users
        # remove currently selected users from searching set
        @next_selection = EtkhProfile.generate_users(LIST_LENGTH, [@selected_users,current_user].flatten)
        @selected_users.concat(@next_selection)
      else
        @next_selection = EtkhProfile.generate_users(LIST_LENGTH,[current_user])
        @selected_users = @next_selection
      end

      # store newly selected users in session variable
      session[:selected_users] = [] if !session[:selected_users]
      @next_selection.each do |user|
        session[:selected_users] << user.id
      end
    end

    # should be AJAX request so render newly selected users only
    if !@next_selection
      render nothing: true
    else
      if session[:search] == false
        render partial: 'profiles_selection', locals: { users: @next_selection }
      else
        # for some strange reason there is a bug which prevents the first
        # render method work for search results, so a JS view is called instead
        render 'etkh_profiles/display_more_search_results'
      end
    end
  end

  def display_profile_hover_info
    @user = User.find_by_id(params[:id])
    @pos_left = params[:left_pos]
    @pos_top = params[:top_pos]
    @page = params[:page]
  end
end
