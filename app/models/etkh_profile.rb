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

  has_many :positions
  has_many :educations

  # can't simply destroy positions and educations
  before_destroy do |profile|
    # remove profile from the position and it will be destroyed if it does not also belong to a member_info
    profile.positions.each do |position|
      position.etkh_profile_id = nil
      position.save
      position.destroy
    end

    # same for educations
    profile.educations.each do |education|
      education.etkh_profile_id = nil
      education.save
      education.destroy
    end
  end


  # public method for profile completeness score
  def get_profile_completeness
    score = calculate_completeness_score
    self.completeness_score = score
    self.save
    return score
  end

  def get_profile_completion_tips
    tips = []

    tips << "Add your current location" if self.user.location.nil? || self.user.location.empty?
    tips << "Add your current organisation" if self.organisation.nil? || self.organisation.empty?
    tips << "Add your current position" if self.current_position.nil? || self.current_position.empty?
    tips << "Add your current industry sector" if self.career_sector.nil? || self.career_sector.empty?
    tips << "Tell the community about your background and interests" if self.background.nil? || self.background.empty?
    tips << "Upload a photo" if !self.user.avatar?
    tips << "Add causes" if !self.profile_option_causes.any?
    tips << "Add high impact activities" if !self.profile_option_activities.any?
    tips << "Add more to your 'background and interests'" if !self.background.nil? && !self.background.empty? && self.background.length < BACKGROUND_MAX_LEN
      
    # sync their account with linkedin ?
    # donation tracking ?
    
    return tips
  end

  def get_background_snippet(minLength, maxLength)
    # returns a maximum of a whole paragraph or maxLength in characters

    return nil if self.background.nil? || self.background.empty?
    
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

    # remove hash tags from end of snippet if any exist
    # this prevents any additional text from being displayed as a heading
    if snippet
      endstr = snippet[-4..-1]
      index = endstr.index("#") if endstr
      snippet = snippet[0..index-5] if index
    end

    return snippet
  end

  def self.generate_users(list_length, current_users = nil)
    return self.gen_users(list_length, current_users)
  end

  ### Metrics ###
  def self.calculate_average_profile_completeness
    total = 0
    count = 0
    User.all.each do |user|
      if user.etkh_profile
        total += user.etkh_profile.completeness_score
        count += 1
      end
    end

    average = total.to_f / count.to_f
    return average.round(2)
  end

  # Calculates the percentage of members who have opted-in for donation declaration since a specified date
  def self.calculate_donation_optin_percentage(start_date)

    # get all members who have signed up since date argument
    members = User.where("created_at >= :start_date", start_date: start_date)

    # cycle through members and calculate percentage
    opted_in = 0
    opted_out = 0
    members.each do |member|
      profile = member.etkh_profile
      if profile
        profile.donation_percentage_optout ? opted_out+=1 : opted_in+=1
      end
    end

    percentage_opted_in = opted_in.to_f / members.length.to_f * 100
    return percentage_opted_in
  end

  # Calculates the median donation percentage value for members who have opted-in, after a certain date
  def self.calculate_median_donation_percentage(start_date)
    # get all members who have signed up since date argument
    members = User.where("created_at >= :start_date", start_date: start_date)

    # cycle through members and create array of donation percentage values
    donations = []
    members.each do |member|
      profile = member.etkh_profile
      if profile
        if profile.donation_percentage_optout == false
          donations << profile.donation_percentage
        end
      end
    end

    # sort values into order
    donations.sort

    # calculate median
    median = donations[donations.length/2]
    return median
  end

  private

  ### Profile completeness ###
  # define percentages for composition of profile score
  PROFILE_PIC = 25
  LOCATION = 5
  ORGANISATION = 5
  CURRENT_POSITION = 5
  CAREER_INDUSTRY = 5
  BACKGROUND = 20
  EXPERIENCE = 5
  EDUCATION = 5
  DONATION_TRACKING = 0
  SKILLS = 5
  HIGH_IMPACT_ACTIVITIES = 5
  CAUSES = 5
  LINKEDIN_PROFILE = 10

  # length of 'background and interests' section after which no more points 
  BACKGROUND_MAX_LEN = 1800

  def calculate_completeness_score
    score = 0

    score += PROFILE_PIC if self.user.avatar?
    
    score += LOCATION if self.user.location && !self.user.location.empty?
    score += ORGANISATION if self.organisation && !self.organisation.empty?
    score += CURRENT_POSITION if self.current_position && !self.current_position.empty?
    score += CAREER_INDUSTRY if self.current_position && !self.current_position.empty?

    # completeness score depends on how long the entry is
    # the score varies linearly until a max cut-off is reached
    if self.background
      len = self.background.length
      if len >= BACKGROUND_MAX_LEN
        score += BACKGROUND
      else
        float = BACKGROUND.to_f / BACKGROUND_MAX_LEN.to_f * len.to_f
        score += float.to_i
      end
    end

    score += HIGH_IMPACT_ACTIVITIES if self.profile_option_activities.any?
    score += CAUSES if self.profile_option_causes.any?

    # skills
    if self.skills_knowledge_learn && !self.skills_knowledge_learn.empty?
      score += SKILLS
    elsif self.skills_knowledge_share && !self.skills_knowledge_share.empty?
      score += SKILLS
    end

    score += EXPERIENCE if self.positions.any?
    score += EDUCATION if self.educations.any?

    score += LINKEDIN_PROFILE if self.user.external_linkedin && !self.user.external_linkedin.empty?

    score += DONATION_TRACKING if self.user.donations.any?

    return score
  end


  ### Generate list of users

  # define minimum requirements
  MIN_PROFILE_COMPLETENESS = 60
  MIN_BACKGROUND_LENGTH = 500
  PROBABILITY_MIN_PROFILE = 0.10

  # threshold is defined by the probability that a profile with min profile completeness
  # will be selected
  THRESHOLD = (1 - PROBABILITY_MIN_PROFILE) * MIN_PROFILE_COMPLETENESS * 10
  RANDOM_GENERATOR = Random.new

  # algorithm for generating users
  def self.gen_users(list_length, current_users = nil)
    all_users = User.includes(:etkh_profile).all
    subset = current_users.nil? ? all_users.shuffle : (all_users - current_users).shuffle
    
    subset.select do |user|
      profile = user.etkh_profile and
      !profile.background.nil? and
      profile.background.length >= MIN_BACKGROUND_LENGTH and
      (completeness = profile.completeness_score) >= MIN_PROFILE_COMPLETENESS and
      RANDOM_GENERATOR.rand(1..10) * (completeness + profile.admin_rating) >= THRESHOLD
    end
    .select(&:avatar?)
    .sample(list_length)
  end

  RATING = 1000
  def self.prioritise_female_profiles
    users_list = ["Abbie Taylor", "Jess Whittlestone", "Holly Morgan", "Roxanne Heston", "Lisanne Pueschel"]

    users_list.each do |username|
      user = User.find_by_name(username)
      user.etkh_profile.admin_rating = RATING
      user.etkh_profile.save
    end
  end
end
