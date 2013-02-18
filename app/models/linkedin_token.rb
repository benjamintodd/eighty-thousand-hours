# holds information for a single set of permissions for linkedin access
# access tokens expire after 60 days
class LinkedinToken < ActiveRecord::Base
  attr_accessible :permissions,
                  :access_token,
                  :access_secret,
                  :last_updated

  belongs_to :linkedin_info
end