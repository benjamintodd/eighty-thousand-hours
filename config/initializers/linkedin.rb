LINKEDIN_CONFIG_BASIC = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_BASIC_EMAIL = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile+r_emailaddress', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_FULL = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_fullprofile', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_INVITE = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=w_messages', :access_token_path => '/uas/oauth/accessToken' }
LINKEDIN_CONFIG_FULL_EMAIL = { :site => 'https://api.linkedin.com', :authorize_path => '/uas/oauth/authenticate', :request_token_path =>'/uas/oauth/requestToken?scope=r_fullprofile+r_emailaddress', :access_token_path => '/uas/oauth/accessToken' }

LinkedIn::Client.class_eval do
  def get_picture
    path = "/people/~/picture-urls::(original)"
    response = get(path)
    url = response[/\[(.*?)\]/][/"(.*?)"/][/"(.*?)"/,1]
    return url
  end

  def get_email
    path = "/people/~/email-address"
    response = get(path)
    return response
  end

  def send_invitation(options)
    if options[:email]
      path = "/people/~/mailbox"
      message = {
        "recipients" => {
          "values" => [
            {
              "person" => {
                "_path" => "/people/email=#{options[:email]}",
                "first-name" => options[:first_name],
                "last-name" => options[:last_name]
              }
            }]
        },
        "subject" => "Invitation to connect.",
        "body" => options[:body],
        "item-content" => {
          "invitation-request" => {
            "connect-type" => "friend"
          }
        }
      }
      response = post(path, message.to_json, "Content-Type" => "application/json")
      return response
    end
  end
end