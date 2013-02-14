class LinkedinInfo < ActiveRecord::Base
  attr_accessible :permissions,
                  :access_token,
                  :access_secret,
                  :last_updated

  belongs_to :user
end