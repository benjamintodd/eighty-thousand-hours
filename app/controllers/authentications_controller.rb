class AuthenticationsController < ApplicationController
  include Devise::Controllers::Rememberable

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env['omniauth.auth']
    auth = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    p omniauth

    if auth
      flash[:"alert-success"] = "You are now signed in."
      remember_me auth.user # set the remember_me cookie
      sign_in_and_redirect(:user, auth.user) 

      # retrospective processing of profile info
      Authentication.process_omniauth_session(omniauth, auth.user)
    elsif current_user
      current_user.authentications.find_or_create_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      flash[:"alert-success"] = "Authentication successful! You can now login using your #{omniauth['provider'].to_s.titleize} account."

      # retrospective processing of profile info
      Authentication.process_omniauth_session(omniauth, auth.user)
      
      redirect_to edit_user_registration_path current_user
    elsif user = User.where( email: omniauth['info']['email'] ).first
      user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      user.save!
      flash[:"alert-success"] = "Your 80,000 Hours account is now linked to your #{omniauth['provider'].to_s.titleize} account, and you have been logged in."

      # retrospective processing of profile info
      Authentication.process_omniauth_session(omniauth, auth.user)

      remember_me user # set the remember_me cookie
      sign_in_and_redirect(:user, user)  
    else
      # store omniauth data in session
      # the 'extra' field can be too big to fit in the session so perhaps it should be dropped?
      # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      session[:omniauth] = omniauth
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

      # process facebook profile info
      Authentication.process_facebook_info(omniauth, user) if omniauth.provider == "facebook"

      # retrospective processing of google profile info
      Authentication.process_omniauth_session(omniauth, user) if omniauth.provider == "google_oauth2"

      # Log this in Google Analytics
      Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "New member", "Created via #{omniauth.provider}")

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
        email = client.get_email[1..-2]

        # create user
        pwd = (0...16).map{ ('a'..'z').to_a[rand(26)] }.join
        user = User.new(:name => name, :email => email, :password => pwd, :password_confirmation => pwd)  
        user.omniauth_signup = false
        user.skip_confirmation!
        user.linkedin_email = email
        user.external_linkedin = client.profile(fields: %w(site-standard-profile-request)).site_standard_profile_request.url

        if user.save
          # Log this in Google Analytics
          Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "New member", "Created via LinkedIn")

          # create linkedin info table
          linkedinfo = LinkedinInfo.new
          linkedinfo.user_id = user.id
          linkedinfo.permissions = "r_basicprofile+r_emailaddress"
          linkedinfo.access_token = session[:access_token]
          linkedinfo.access_secret = session[:access_secret]
          linkedinfo.last_updated = Time.now
          linkedinfo.save

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
    elsif current_user.linkedin_email && !current_user.linkedin_email.empty?
      current_user.linkedin_info.destroy
      current_user.linkedin_email = nil
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

    # if this is a 'link account to linkedin' request for
    # an existing account, notify callback action that this is the case
    if params[:linking] == "true" && user_signed_in?
      session[:linking] = "true"
    end

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

      # if initial request was made by an existing user to link their account to linkedin
      if user_signed_in? && session[:linking] == "true"
        session[:linking] = nil

        Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "LinkedIn", "User linked account with LinkedIn", user.id)

        # create linkedin info table
        linkedinfo = LinkedinInfo.new
        linkedinfo.user_id = current_user.id
        linkedinfo.permissions = "r_basicprofile+r_emailaddress"
        linkedinfo.access_token = atoken
        linkedinfo.access_secret = asecret
        linkedinfo.last_updated = Time.now
        linkedinfo.save

        # store email and LinkedIn profile url
        current_user.linkedin_email = client.get_email[1..-2]
        current_user.external_linkedin = client.profile(fields: %w(site-standard-profile-request)).site_standard_profile_request.url
        current_user.save

        # redirect if not an AJAX request
        unless request.xhr?
          session[:new_profile] = true
          redirect_to edit_user_etkh_profile_path(current_user, current_user.etkh_profile)
        end
      else
        # new user
        # access tokens are stored in database when user is created
        redirect_to '/authentications/create_new_account'
      end
    else
      # can simply authorize from access tokens already requested
      client.authorize_from_access(session[:access_token], session[:access_secret])
      redirect_to '/dashboard' # ?
    end
  end


  def linkedin_signin
    # action is called when user tries to sign-in via linkedin

    # need to perform basic authorisation with linkedin
    # in order to get email address, by which the user can be identified

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
    email = client.get_email[1..-2]

    # check if user account exists
    if user = User.find_by_email(email)
      # create linkedin_info table if not already exist
      if !user.linkedin_info
        linkedin_info = LinkedinInfo.new
        linkedin_info.user_id = user.id
      else
        linkedin_info = user.linkedin_info
      end

      # always store latest access tokens
      linkedin_info.permissions = "r_basicprofile+r_emailaddress"
      linkedin_info.access_token = atoken
      linkedin_info.access_secret = asecret
      linkedin_info.last_updated = Time.now
      linkedin_info.save

      # store email and LinkedIn profile url
      user.linkedin_email = client.get_email[1..-2]
      user.external_linkedin = client.profile(fields: %w(site-standard-profile-request)).site_standard_profile_request.url
      user.save
      
      # redirect to dashboard
      flash[:"alert-success"] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
      #redirect_to '/dashboard'
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

    # always store latest access tokens
    if current_user.linkedin_info
      current_user.linkedin_info.update_attributes( \
        permissions: "r_fullprofile", access_token: atoken, access_secret: asecret, last_updated: Time.now)
    end

    # pull profile data
    User.add_linkedin_to_profile(client, current_user)

    # return to edit member profile
    flash[:"alert-success"] = "Profile data successfully pulled from LinkedIn."
    redirect_to edit_user_etkh_profile_path(current_user, current_user.etkh_profile)

    # log event in google analytics
    Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "LinkedIn", "LinkedIn profile pulled", current_user.id)
  end


  def linkedin_getprofile_and_link_account
    # called when new user wants to pull profile data and link their account

    # create linkedin client
    config = LINKEDIN_CONFIG_FULL_EMAIL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # set up callback action
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/authentications/linkedin_getprofile_and_link_account_callback")

    # reset session access tokens
    session[:access_token] = nil
    session[:access_secret] = nil

    # get request tokens
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    # redirect to linkedin for permission
    redirect_to client.request_token.authorize_url
  end

  def linkedin_getprofile_and_link_account_callback
    # create linkedin client
    config = LINKEDIN_CONFIG_FULL_EMAIL
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # authorise user using latest request tokens
    pin = params[:oauth_verifier]
    atoken, asecret = client.authorize_from_request(session[:request_token], session[:request_secret], pin)

    # create linkedin info table
    linkedinfo = LinkedinInfo.new
    linkedinfo.user_id = current_user.id
    linkedinfo.permissions = "r_fullprofile+r_emailaddress"
    linkedinfo.access_token = atoken
    linkedinfo.access_secret = asecret
    linkedinfo.last_updated = Time.now
    linkedinfo.save

    # store email and LinkedIn profile url
    current_user.linkedin_email = client.get_email[1..-2]
    current_user.external_linkedin = client.profile(fields: %w(site-standard-profile-request)).site_standard_profile_request.url
    current_user.save

    # pull profile data
    User.add_linkedin_to_profile(client, current_user)

    # return to edit member profile
    flash[:"alert-success"] = "Profile data successfully pulled from LinkedIn."
    redirect_to edit_user_etkh_profile_path(current_user, current_user.etkh_profile)

    # log event in google analytics
    Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "LinkedIn", "LinkedIn profile pulled", current_user.id)
  end


  def linkedin_invite_connection
    # called when user tries to invite another member as a connection on linkedin
    
    session[:email] = params[:email]
    session[:user_id] = params[:user_id]
    
    # user must be signed in
    unless user_signed_in?
      # if AJAX request simply display modal
      if request.xhr?
        render 'shared/sign_up_modal'
      else
        # display error page
        @error_type = "signup"
        render 'shared/display_error'
      end
      return
    end

    # create linkedin client
    config = LINKEDIN_CONFIG_INVITE
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # check for existing access tokens for messaging
    linkedinfo = current_user.linkedin_info
    if linkedinfo && linkedinfo.permissions.include?("w_messages")
      # check if still valid
      time_elapsed = Time.now - linkedinfo.last_updated #seconds
      time_elapsed = time_elapsed / 60 / 60 / 24 #days
      
      if time_elapsed < 60
        # authorise with existing tokens
        client.authorize_from_access(linkedinfo.access_token, linkedinfo.access_secret)

        # send invitation
        response = client.send_invitation({email: session[:email]})
        
        # confirm
        if response.code == "201" || response.code == "200"
          flash[:"alert-success"] = "An invitation to connect has been sent to the user's LinkedIn account."
          Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "LinkedIn", "LinkedIn connection invitation sent", user.id)
        else
          flash[:"alert-error"] = "Sorry! There seems to have been a problem sending an invitation to connect."
        end
        
        # return
        flash[:"alert-success"] = "An invitation to connect has been sent to the user's LinkedIn account."
        user = User.find_by_id(session[:user_id])
        if user
          redirect_to etkh_profile_path(user, user.etkh_profile)
        else
          redirect_to '/'
        end
        
        return
      end
    end

    # otherwise need to request tokens

    # set up callback action
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/authentications/linkedin_invite_connection_callback")

    # reset session access tokens
    session[:access_token] = nil
    session[:access_secret] = nil

    # get request tokens
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    # redirect to linkedin for permission
    redirect_to client.request_token.authorize_url
  end

  def linkedin_invite_connection_callback
    # create linkedin client
    config = LINKEDIN_CONFIG_INVITE
    client = LinkedIn::Client.new(ENV['LINKEDIN_AUTH_KEY'], ENV['LINKEDIN_AUTH_SECRET'], config)

    # authorise from request tokens
    pin = params[:oauth_verifier]
    atoken, asecret = client.authorize_from_request(session[:request_token], session[:request_secret], pin)

    # send invitation
    puts "about to send invitation: #{session[:email]}"
    response = client.send_invitation({email: session[:email]})

    # store access tokens
    if current_user.linkedin_info
      linkedinfo = current_user.linkedin_info
    else
      linkedinfo = LinkedinInfo.new
      linkedinfo.user_id = current_user.id
    end
    linkedinfo.permissions = "w_messages"
    linkedinfo.access_token = atoken
    linkedinfo.access_secret = asecret
    linkedinfo.last_updated = Time.now
    linkedinfo.save

    # confirm
    if response.code == "201" || response.code == "200"
      flash[:"alert-success"] = "An invitation to connect has been sent to the user's LinkedIn account."
      Gabba::Gabba.new("UA-27180853-1", "80000hours.org").event("Members", "LinkedIn", "LinkedIn connection invitation sent", user.id)
    else
      flash[:"alert-error"] = "Sorry! There seems to have been a problem sending an invitation to connect."
    end

    # return
    user = User.find_by_id(session[:user_id])
    if user
      redirect_to etkh_profile_path(user, user.etkh_profile)
    else
      redirect_to '/'
    end
  end  
end
