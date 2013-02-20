# holds all relevant information for linkedin
class LinkedinInfo < ActiveRecord::Base
	belongs_to :user

  attr_accessible :permissions,
                  :access_token,
                  :access_secret,
                  :last_updated
end