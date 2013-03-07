class EtkhProfile < ActiveRecord::Base
  belongs_to :user

  attr_accessible :background,
                  :career_plans,
                  :confirmed,
                  :inspiration,
                  :interesting_fact,
                  :occupation,
                  :organisation,
                  :current_position,
                  :career_sector,
                  :organisation_role,
                  :doing_good_inspiring,
                  :doing_good_research,
                  :doing_good_philanthropy,
                  :doing_good_prophilanthropy,
                  :doing_good_innovating,
                  :doing_good_improving,
                  :public_profile,
                  :skills_knowledge_share,
                  :skills_knowledge_learn,
                  :causes_comment,
                  :profile_option_cause_ids,
                  :activities_comment,
                  :profile_option_activity_ids,
                  :donation_percentage,
                  :donation_percentage_optout

  # now we can access @etkh_profile.name etc.
  delegate :name, :name=, 
           :location, :location=,
           :to => :user

  scope :newest, order("created_at DESC")

  has_and_belongs_to_many :profile_option_causes
  has_and_belongs_to_many :profile_option_activities

  has_many :positions, :dependent => :destroy
  has_many :educations, :dependent => :destroy


  # public method for profile completeness score
  def get_profile_completeness
    calculate_completeness_score
  end

  # public method which returns a suggestion for what the user
  # should do to improve their profile
  def get_suggested_profile_addition
    ## in order of precedence

    # add location
    if self.location.nil?
      "Add your current location"
    # add organisation
    elsif self.organisation.nil?
      "Add your current organisation"
    # profile photo
    elsif !self.user.avatar?
      "Upload a photo to your profile so members "
    # add background info if none already
    elsif !self.background?
      "Fill out your 'background and interests' and tell us why you are here"
    # sync their account with linkedin ?

    # add causes
    elsif !self.profile_option_causes.any?
      "Let us know what you care about and add causes to your profile"
    # add high impact activities
    elsif !self.profile_option_activities.any?
      "What are you doing to make a difference? Add your high impact activities to your profile"
    # improve background if not long
    elsif self.background.length < BACKGROUND_MAX_LEN
      "Tell us more about yourself by adding to your 'background and interests'"
    # donation tracking ?
    end
  end

  def get_background_snippet(minLength, maxLength)
    # returns a maximum of a whole paragraph or maxLength in characters

    # strip leading white spaces
    stripped = self.background.lstrip

    # get only first paragraph
    snippet = stripped[/(.*)/]

    # if first paragraph is too short get more text
    if snippet.length < minLength
      snippet = stripped[0..minLength]
    else
      # otherwise get max length
      snippet = snippet[0..maxLength]
    end
    snippet
  end

  def self.generate_users(list_length, current_users = nil)
    return self.gen_users(list_length, current_users)
  end


  private

  ### Profile completeness ###
  # define percentages for composition of profile score
  PROFILE_PIC = 25
  INFO_LOCATION = 5
  INFO_ORGANISATION = 5
  BACKGOUND = 15
  EXPERIENCE = 5
  DONATION_TRACKING = 5
  SKILLS = 5
  HIGH_IMPACT_ACTIVITIES = 10
  CAUSES = 10
  LINKEDIN_PROFILE = 15

  # length of 'background and interests' section after which no more points 
  BACKGROUND_MAX_LEN = 1000

  def calculate_completeness_score
    score = 0

    # profile photo
    score += PROFILE_PIC if self.user.avatar?

    # basic information
    score += INFO_LOCATION if self.location
    score += INFO_ORGANISATION if self.organisation

    # background and interests
    # completeness score depends on how long the entry is
    # the score varies linearly until a max cut-off is reached
    if self.background
      len = self.background.length
      if len >= BACKGROUND_MAX_LEN
        score += BACKGOUND
      else
        float = BACKGOUND.to_f / BACKGROUND_MAX_LEN.to_f * len.to_f
        score += float.to_i
      end
    end

    # high impact activities
    score += HIGH_IMPACT_ACTIVITIES if self.profile_option_activities.any?

    # causes
    score += CAUSES if self.profile_option_causes.any?

    # donation tracking ?
    # experience
    # skills
    # linkedin profile ?

    return score
  end


  ### Generate list of users

  # define minimum requirements
  MIN_PROFILE_COMPLETENESS = 50
  MIN_BACKGROUND_LENGTH = 500
  PROBABILITY_MIN_PROFILE = 0.50

  # threshold is defined by the probability that a profile with min profile completeness
  # will be selected
  THRESHOLD = (1 - PROBABILITY_MIN_PROFILE) * MIN_PROFILE_COMPLETENESS * 10
  RANDOM_GENERATOR = Random.new

  # algorithm for generating users
  def self.gen_users(list_length, current_users = nil)
    subset = current_users.nil? ? User.all : (User.all - current_users)
    
    subset.select do |user|
      profile = user.etkh_profile and
      !profile.background.nil? and
      profile.background.length >= MIN_BACKGROUND_LENGTH and
      (completeness = profile.get_profile_completeness) >= MIN_PROFILE_COMPLETENESS and
      RANDOM_GENERATOR.rand(1..10) * completeness >= THRESHOLD
    end
    .select(&:avatar?)
    .sample(list_length)
  end
end
