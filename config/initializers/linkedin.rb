LINKEDIN_CONFIG_BASIC = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_BASIC_EMAIL = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile+r_emailaddress', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_FULL = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_fullprofile', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_INVITE = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=w_messages', :access_token_path => '/uas/oauth/accessToken' }

LinkedIn::Client.class_eval do
  def get_email
    path = "/people/~/email-address"
    response = get(path)
    response
  end
end