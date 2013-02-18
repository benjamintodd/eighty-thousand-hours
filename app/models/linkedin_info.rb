# holds all relevant information for linkedin objects
class LinkedinInfo < ActiveRecord::Base
	belongs_to :user
	has_many :linkedin_tokens, :dependent => :destroy

  # there are a number of types of access requested by the site at separate times
  # each permission type is stored separately

  def basic_token
    LinkedinToken.find_by_id(self.basic_token_id)
  end
  def basic_email_token
    LinkedinToken.find_by_id(self.basic_email_token_id)
  end
  def full_token
    LinkedinToken.find_by_id(self.full_token_id)
  end
  def invite_token
    LinkedinToken.find_by_id(self.invite_token_id)
  end
end