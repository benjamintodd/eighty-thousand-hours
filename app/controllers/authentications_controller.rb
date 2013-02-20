class AuthenticationsController < ApplicationController
  include Devise::Controllers::Rememberable

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env['omniauth.auth']
    auth = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if auth
      flash[:"alert-success"] = "You are now signed in."
      remember_me auth.user # set the remember_me cookie
      sign_in_and_redirect(:user, auth.user) 
    elsif current_user
      current_user.authentications.find_or_create_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      flash[:"alert-success"] = "Authentication successful! You can now login using your #{omniauth['provider'].to_s.titleize} account."
      redirect_to edit_user_registration_path current_user
    elsif user = User.where( email: omniauth['info']['email'] ).first
      user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      user.save!
      flash[:"alert-success"] = "Your 80,000 Hours account is now linked to your #{omniauth['provider'].to_s.titleize} account, and you have been logged in."
      remember_me user # set the remember_me cookie
      sign_in_and_redirect(:user, user)  
    else
      # store omniauth data in session
      # the 'extra' field can be too big to fit in the session so we drop it
      # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      session[:omniauth] = omniauth.except('extra')
      redirect_to accounts_merge_url
    end  
  end

  def create_new_account
    omniauth = session[:omniauth]
    if omniauth
      pwd = (0...16).map{ ('a'..'z').to_a[rand(26)] }.join
      user = User.new(:name => omniauth['info']['name'], :email => omniauth['info']['email'], :password => pwd, :password_confirmation =>pwd)  
      user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])  
      user.omniauth_signup = true
      user.skip_confirmation!
      user.save

      # Log this in Google Analytics
      log_event("Members", "Created via Omniauth", user.name, user.id)

      UserMailer.welcome_email(user).deliver!

      flash[:"alert-success"] = "We've linked your #{omniauth['provider'].to_s.titleize} account!<br/>You are signed in to 80,000 Hours with the name #{user.name}".html_safe

      remember_me user # set the remember_me cookie
      sign_in_and_redirect(:user, user) # devise helper method
    else
      # check if user has signuped with linkedin
      if !session[:access_token].nil?
        # connect to linkedin profile
        config = LINKEDIN_CONFIG_BASIC_EMAIL
        client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)
        client.authorize_from_access(session[:access_token], session[:access_secret])

        # get name and email
        name = client.profile[:"first-name"] + " " + client.profile[:"last-name"]
        email = client.get_email

        # create user
        pwd = (0...16).map{ ('a'..'z').to_a[rand(26)] }.join
        user = User.new(:name => name, :email => email, :password => pwd, :password_confirmation => pwd)  
        user.omniauth_signup = false
        user.skip_confirmation!
        user.linkedin_connection = true

        if user.save
          # Log this in Google Analytics
          log_event("Members", "Created via LinkedIn", user.name, user.id)

          # create linkedin info table
          linkedinfo = create_linkedin_info_table(user)
          linkedinfo.basic_email_token.update_attributes( \
            access_token: session[:access_token], access_secret: session[:access_secret], last_updated: Time.now)

          # deliver welcome mail
          UserMailer.welcome_email(user).deliver!

          flash[:"alert-success"] = "We've linked your LinkedIn account!<br/>You are signed in to 80,000 Hours with the name #{user.name}".html_safe

          remember_me user # set the remember_me cookie
          sign_in_and_redirect(:user, user) # devise helper method
        else
          # error
          flash[:"alert-error"] = "Sorry! There seems to have been a problem linking your account to LinkedIn"
          redirect_to '/'
        end
      else
        redirect_to new_user_registration_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if @authentication
      @authentication.destroy
      flash[:notice] = "Your account is no longer linked to #{@authentication.provider.titleize}."
    elsif current_user.linkedin_connection
      current_user.linkedin.destroy
      current_user.update_attributes(linkedin_connection: false)
      flash[:notice] = "Your account is no longer linked to LinkedIn."
    end
    
    redirect_to edit_user_registration_path
  end

  def failure
    flash[:notice] = "Failed to authenticate! Message was: '#{params[:message]}'"
    redirect_to edit_user_registration_path
  end


  ### LinkedIn API

  def linkedin_signup
    # action is called when a user first tries to sign up via his linkedin account

    # create linkedin client and set up callback action
    config = LINKEDIN_CONFIG_BASIC_EMAIL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/authentications/linkedin_signup_callback")

    # reset session access tokens
    session[:access_token] = nil
    session[:access_secret] = nil

    # get request tokens
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    # redirect to linkedin for permission
    redirect_to client.request_token.authorize_url
  end

  def linkedin_signup_callback
    # action is called after return from linkedin when 'linkedin_signup' has been called

    # create linkedin client
    config = LINKEDIN_CONFIG_BASIC_EMAIL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # action may have already been called recently
    # in which case we already have access tokens
    if session[:access_token].nil?
      # get access tokens
      pin = params[:oauth_verifier]
      atoken, asecret = client.authorize_from_request(session[:request_token], session[:request_secret], pin)
      session[:access_token] = atoken
      session[:access_secret] = asecret

      # access tokens are stored in database when user is created
      redirect_to '/authentications/create_new_account'
    else
      # can simply authorize from access tokens already requested
      client.authorize_from_access(session[:access_token], session[:access_secret])
      redirect_to '/dashboard' # ?
    end
  end


  def linkedin_signin
    # action is called when user tries to sign-in via linkedin

    # need to perform basic authorisation with linkedin
    # in order to get user name, by which the user can be identified

    # create linkedin client
    config = LINKEDIN_CONFIG_BASIC_EMAIL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # set up callback action
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/authentications/linkedin_signin_callback")

    # reset session access tokens
    session[:access_token] = nil
    session[:access_secret] = nil

    # get request tokens
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    # redirect to linkedin for permission
    redirect_to client.request_token.authorize_url
  end

  def linkedin_signin_callback
    # action is called after return from linkedin when linkedin_signin was called
    
    # first create linkedin client
    config = LINKEDIN_CONFIG_BASIC_EMAIL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # authorise user using latest request tokens
    pin = params[:oauth_verifier]
    atoken, asecret = client.authorize_from_request(session[:request_token], session[:request_secret], pin)
    
    # get user email
    email = client.get_email

    # check if user account exists
    if user = User.find_by_email(email)
      # store tokens whether they already exist or not
      # even if there are already existing ones these are more recent
      user.linkedin_info.basic_email_token.update_attributes( \
        access_token: atoken.to_s, access_secret: asecret.to_s, last_updated: Time.now)

      # redirect to dashboard
      flash[:"alert-success"] = "Signed in successfully."
      sign_in(:user, user)
      redirect_to '/dashboard'
    else
      flash[:"alert-error"] = "An 80,000 Hours account does not currently exist for this LinkedIn account"
      redirect_to '/'
    end
  end


  def linkedin_getprofile
    # called when user chooses to pull linkedin profile data

    # create linkedin client
    config = LINKEDIN_CONFIG_FULL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # check for existing access tokens for full profile
    puts "linkedin_connection: #{current_user.linkedin_connection}"
    puts "token: #{current_user.linkedin_info.full_token.access_token}"
    if current_user.linkedin_connection && current_user.linkedin_info.full_token.access_token
      puts "user has linkedin info and previous full token"
      # check if still valid
      time_elapsed = Time.now - current_user.linkedin_info.full_token.last_updated  #seconds
      time_elapsed = time_elapsed / 60 / 60 / 24  #days
      
      if time_elapsed < 60
        puts "full profile tokens are still valid"
        # authorise with existing access tokens
        token = current_user.linkedin_info.full_token.access_token
        secret = current_user.linkedin_info.full_token.access_secret
        response = client.authorize_from_access(token, secret)
        puts "response: #{response}"

        # pull profile data
        add_linkedin_to_profile(client, current_user)

        # return to edit member profile
        redirect_to edit_user_etkh_profile_path(current_user, current_user.etkh_profile)
        return
      end
    end

    # otherwise need to get tokens for full profile access

    # set up callback action
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/authentications/linkedin_getprofile_callback")

    # reset session access tokens
    session[:access_token] = nil
    session[:access_secret] = nil

    # get request tokens
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    # redirect to linkedin for permission
    redirect_to client.request_token.authorize_url
  end

  def linkedin_getprofile_callback
    # create linkedin client
    config = LINKEDIN_CONFIG_FULL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # authorise user using latest request tokens
    pin = params[:oauth_verifier]
    atoken, asecret = client.authorize_from_request(session[:request_token], session[:request_secret], pin)

    # if user has not used linkedin before need to create table
    if current_user.linkedin_connection != true
      puts "creating user linkedin info"
      current_user.update_attributes(linkedin_connection: true)
      create_linkedin_info_table(current_user)
    end

    # store access tokens
    current_user.linkedin_info.full_token.update_attributes( \
      access_token: atoken, access_secret: asecret, last_updated: Time.now)

    # pull profile data
    add_linkedin_to_profile(client, current_user)
    puts "location: #{current_user.etkh_profile.location}"

    # return to edit member profile
    redirect_to edit_user_etkh_profile_path(current_user, current_user.etkh_profile)
  end


  private

  def add_linkedin_to_profile(client, user)
    # test
    user.etkh_profile.background = client.profile(fields: %w(educations)).to_s
    puts user.etkh_profile.background
    user.etkh_profile.location = "new location"
    puts user.etkh_profile.location
  end

  def create_linkedin_info_table(user)
    # create linkedin info table
    linkedinfo = LinkedinInfo.new
    linkedinfo.user_id = user.id

    # create linkedin tokens
    basic_token = LinkedinToken.new
    basic_token.permissions = "r_basicprofile"
    basic_token.save
    basic_email_token = LinkedinToken.new
    basic_email_token.permissions = "r_basicprofile+r_emailaddress"
    basic_email_token.save
    full_token = LinkedinToken.new
    full_token.permissions = "r_fullprofile"
    full_token.save
    invite_token = LinkedinToken.new
    invite_token.permissions = "w_messages"
    invite_token.save

    # add token ids to linkedin info table so they can be accessed later
    linkedinfo.basic_token_id = basic_token.id
    linkedinfo.basic_email_token_id = basic_email_token.id
    linkedinfo.full_token_id = full_token.id
    linkedinfo.invite_token_id = invite_token.id
    linkedinfo.save

    return linkedinfo
  end
end
