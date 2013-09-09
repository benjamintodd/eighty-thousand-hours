require 'open-uri'
class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  attr_accessible :name,
                  :email,
                  :password,
                  :password_confirmation,
                  :rememember_me,
                  :avatar,
                  :location,
                  :phone,
                  :on_team,
                  :team_role,
                  :team_role_id,
                  :external_website,
                  :external_twitter,
                  :external_facebook,
                  :external_linkedin,
                  :real_name,
                  :contacted_date,
                  :contacted_by,
                  :etkh_profile_attributes

  delegate :public_profile, :to => :etkh_profile

  has_one :linkedin_info, :dependent => :destroy
  has_one :member_info, :dependent => :destroy

  # omniauth authentication
  has_many :authentications, :dependent => :destroy

  # comments on posts
  has_many :comments, :dependent => :destroy

  # dependent means 80k profile gets destroyed when user is destroyed
  has_one :etkh_profile, :dependent => :destroy
  accepts_nested_attributes_for :etkh_profile
  before_create :build_default_profile
  after_create :create_info_table

  # a user can write many blog posts
  has_many :blog_posts

  # note that Devise handles the validation for email and password
  validates_presence_of   :name, :message => "You must tell us your name"

  # paperclip avatars on S3
  has_attached_file :avatar, {
                      :styles => { :medium => "200x200", :small => "100x100#", :thumb => "64x64#" },
                      :default_url => "/assets/profiles/avatar_default_200x200.png",
                      :path => "/avatars/:style/:id/:filename"
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  validates_attachment_size :avatar, :less_than => 2.megabytes,
                            :unless => Proc.new {|m| m[:image].nil?}
  validates_attachment_content_type :avater, :content_type=>['image/jpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new {|m| m[:image].nil?}

  def avatar_from_url(url)
    if url && !url.empty?
      io = open(URI.parse(url))
      def io.original_filename; base_uri.path.split('/').last; end
      self.avatar = io.original_filename.blank? ? nil : io
      self.avatar_remote_url = url
      return true
    else
      return false
    end
  end
  
  # e.g. Admin, BlogAdmin, WebAdmin
  has_and_belongs_to_many :roles
  
  # a User can have a TeamRole (e.g. Events, Communications)
  belongs_to :team_role

  # a User can create lots of donations
  has_many :donations

  scope :alphabetical, order("name ASC")
  scope :newest, order("created_at DESC")
  
  def has_role?(symbol)
    roles.map {|r| r.name.underscore.to_sym }
         .include? symbol.to_s.underscore.to_sym
  end

  scope :etkh_members, joins(:etkh_profile)
  scope :non_etkh_members, lambda { includes(:etkh_profile).where('etkh_profiles.id is null') }

  def eighty_thousand_hours_member?
    self.etkh_profile
  end

  def first_name
    name.split.first
  end

  def last_name
    name.split.last
  end

  def external_links?
    external_website? || external_twitter? || external_linkedin? || external_facebook?
  end
  
  def self.with_team_role(role)
    where(on_team: true).find_all{|u| (u.team_role.name == role)}
  end

  # for active admin dashboard
  def admin_permalink
    admin_user_path(self)
  end

  def total_confirmed_donations
    donations.confirmed.sum(:amount)
  end

  def self.to_csv(options = {})
    columns = ["id", "name", "email", "sign_in_count", "last_sign_in_at", "created_at", "location", "organisation", "background", "skills_knowledge_share", "skills_knowledge_learn", "donation_percentage", "donation_percentage_optout", "external twitter", "external facebook", "external_linkedin", "external_website", "DOB", "gender"]
    CSV.generate(options) do |csv|
      csv << columns
      self.all.each do |user|
        if user.etkh_profile
          if user.member_info
            entries = [user.id, user.name, user.email, user.sign_in_count, user.last_sign_in_at, user.created_at, user.location, user.etkh_profile.organisation, user.etkh_profile.background, user.etkh_profile.skills_knowledge_share, user.etkh_profile.skills_knowledge_learn, user.etkh_profile.donation_percentage, user.etkh_profile.donation_percentage_optout, user.external_twitter, user.external_facebook, user.external_linkedin, user.external_website, user.member_info.DOB, user.member_info.gender]
          else
            entries = [user.id, user.name, user.email, user.sign_in_count, user.last_sign_in_at, user.created_at, user.location, user.etkh_profile.organisation, user.etkh_profile.background, user.etkh_profile.skills_knowledge_share, user.etkh_profile.skills_knowledge_learn, user.etkh_profile.donation_percentage, user.etkh_profile.donation_percentage_optout, user.external_twitter, user.external_facebook, user.external_linkedin, user.external_website, nil, nil]
          end
        else
          entries = [user.id, user.name, user.email, user.sign_in_count, user.last_sign_in_at, user.created_at, user.location, nil, nil, nil, nil, nil, user.external_twitter, user.external_facebook, user.external_linkedin, user.external_website, nil, nil]
        end
        csv << entries
      end
    end
  end

  def self.add_linkedin_to_profile(client, user)
    # update data fields with relevant info from linkedin profile

    profile = user.etkh_profile

    # create memberinfo table if not already exist
    if !user.member_info
      memberinfo = MemberInfo.new
      memberinfo.user_id = user.id
    else
      memberinfo = user.member_info
    end

    user.location = client.profile(fields: %w(location)).location.name
    profile.career_sector = client.profile(fields: %w(industry)).industry
    user.external_linkedin = client.profile(fields: %w(site-standard-profile-request)).site_standard_profile_request.url

    if !user.avatar || user.avatar.to_s.include?("avatar_default")
      url = client.get_picture
      user.avatar_from_url(url) if url && !url.empty?
    end

    # store date of birth in member info table
    dob = client.profile(fields: %w(date-of-birth)).date_of_birth
    if !dob.nil?
      year = dob.year
      month = dob.month ? dob.month : 01
      day = dob.day ? dob.day : 01
      memberinfo.DOB = DateTime.new(year,month,day) if year
    end
    memberinfo.save

    ## get list of positions
    positions = client.profile(fields: %w(positions)).positions.all
    positions.each do |position|
      # check for existing position
      t = nil
      if profile.positions
        profile.positions.each do |p| 
          if p.position == position.title && p.organisation == position.company.name
            t = Position.find_by_id(p.id)
            break
          end
        end
      end
      
      t = Position.new unless t

      t.position = position.title if position.title
      t.organisation = position.company.name if position.company.name
      t.start_date_month = convert_month(position.start_date.month) if position.start_date.month
      t.start_date_year = position.start_date.year if position.start_date.year
      
      if position.is_current != true
        t.end_date_month = convert_month(position.end_date.month) if position.end_date.month
        t.end_date_year = position.end_date.year if position.end_date.year
      else
        t.current_position = true
        profile.organisation = t.organisation
        profile.current_position = t.position
      end
      t.etkh_profile_id = profile.id
      t.save
    end

    ## get list of educations
    # for some strange and unknown reason the mash returned for educations from the profile
    # returns an error when queried for items within it(eg 'degree') so I have had to parse the
    # Mash myself using regex
    educations = client.profile(fields: %w(educations)).educations
    educations.all.each do |education|
      # get data
      string = education.to_s
      string_array = string.split

      university = string[string.index("school_name")+13..-1][/(.*?)"/][0..-2] if string.index("school_name")
      course = string[string.index("field_of_study")+16..-1][/(.*?)"/][0..-2] if string.index("field_of_study")
      qualification = string[string.index("degree")+8..-1][/(.*?)"/][0..-2] if string.index("degree")

      start_date_year = nil
      end_date_year = nil
      string_array.each_with_index do |str, index|
        if str.include?("start_date")
          start_date_year = string_array[index+1][/\d+/]
        elsif str.include?("end_date")
          end_date_year = string_array[index+1][/\d+/]
        end
      end

      # check for existing education
      t = nil
      if profile.educations
        profile.educations.each do |e|
          if e.university == university && e.course == course
            t = Education.find_by_id(e.id)
            break
          end
        end
      end

      # otherwise create new education table
      t = Education.new unless t

      t.university = university if university
      t.course = course if course
      t.qualification = qualification if qualification
      t.start_date_year = start_date_year if start_date_year
      t.end_date_year = end_date_year if end_date_year
      t.etkh_profile_id = profile.id
      t.save
    end

    user.save

    # recalculate profile completeness
    profile.get_profile_completeness
  end

  # static method that generates a list of users with good profiles
  def self.generate_users_list(list_size)
    # create new UsersSelection object
    selection = UsersSelection.new(list_size)
    # return object
    return selection
  end

  def self.search(options)
    # define search conditions
    # search terms are case-insensitive
    user_conditions_array = []
    user_conditions_array << [ 'lower(name) LIKE ?', "%#{options[:name].downcase}%" ] if !options[:name].empty?
    user_conditions_array << [ 'lower(location) LIKE ?', "%#{options[:location].downcase}%" ] if !options[:location].empty?    

    # concatenate conditions into search string
    user_conditions = build_search_conditions(user_conditions_array)
    user_results = User.where(user_conditions).all

    # now search etkh_profiles 
    profiles_conditions_array = []
    profiles_conditions_array << [ 'lower(organisation) LIKE ?', "%#{options[:organisation].downcase}%" ] if !options[:organisation].empty?
    profiles_conditions_array << [ 'lower(career_sector) LIKE ?', "%#{options[:industry].downcase}%" ] if !options[:industry].empty?
    profiles_conditions_array << [ 'lower(current_position) LIKE ?', "%#{options[:position].downcase}%" ] if !options[:position].empty?

    profile_conditions = build_search_conditions(profiles_conditions_array)
    profile_results = EtkhProfile.where(profile_conditions).all
    
    # convert array of profiles into array of users
    user_profile_results = profile_results.map{|p|p.user}

    results = user_results & user_profile_results

    # perform search by keyword if it exists
    if !options[:keyword].empty?
      keyword_search_results = search_by_keyword(options[:keyword]) 
      results = results & keyword_search_results
    end

    # find common elements in both results arrays
    return results
  end

  def self.search_by_keyword(keyword)
    keyword = keyword.downcase

    results = []
    results << User.where([ 'lower(name) LIKE ?', "%#{keyword}%" ])
    results << User.where([ 'lower(location) LIKE ?', "%#{keyword}%" ])

    results << EtkhProfile.where([ 'lower(organisation) LIKE ?', "%#{keyword}%" ]).map{|p| p.user}
    results << EtkhProfile.where([ 'lower(career_sector) LIKE ?', "%#{keyword}%" ]).map{|p| p.user}
    results << EtkhProfile.where([ 'lower(current_position) LIKE ?', "%#{keyword}%" ]).map{|p| p.user}
    results << EtkhProfile.where([ 'lower(background) LIKE ?', "%#{keyword}%" ]).map{|p| p.user}
    results << EtkhProfile.where([ 'lower(skills_knowledge_share) LIKE ?', "%#{keyword}%" ]).map{|p| p.user}
    results << EtkhProfile.where([ 'lower(skills_knowledge_learn) LIKE ?', "%#{keyword}%" ]).map{|p| p.user}

    results = results.flatten.uniq
    return results
  end

  def self.sort_by_profile_completeness(users)
    sorted = users.sort do |a,b|
      if a.etkh_profile
        if !b.etkh_profile
          -1
        else
          if a.etkh_profile.completeness_score > b.etkh_profile.completeness_score
            -1
          else
            1
          end
        end
      else
        if b.etkh_profile
          1
        else
          0
        end
      end
    end
  end

  # method to calculate user's karma score
  def get_karma_score
    #TODO Remove Karma Scores
    return 0 #proxy value while we destroy.
  end


  ## Calculations for metrics
  def self.calculate_avatar_percentage(start_date = nil)
    avatar_count = 0
    if !start_date
      users = User.all
    else
      users = User.where("created_at >= :start_date", start_date: start_date)
    end

    total = users.length
    users.each do |user|
      avatar_count += 1 if user.avatar && !user.avatar.to_s.include?("avatar_default")
    end
    return (avatar_count.to_f / total.to_f * 100).round(2)
  end

  def self.active_link?(url)
    uri = URI.parse(url)
    response = nil
    Net::HTTP.start(uri.host, uri.port) { |http|
      response = http.head(uri.path.size > 0 ? uri.path : "/")
    }  
    return response.code == "200"
  end

  private
  def build_default_profile
    # build default profile instance. Will use default params.
    # The foreign key to the owning User model is set automatically
    build_etkh_profile
    true # Always return true in callbacks as the normal 'continue' state
         # Assumes that the default_profile can **always** be created.
         # or
         # Check the validation of the profile. If it is not valid, then
         # return false from the callback. Best to use a before_validation
         # if doing this. View code should check the errors of the child.
         # Or add the child's errors to the User model's error array of the :base
         # error item
  end

  def self.build_search_conditions(conditions_array)
    conditions = []
    arguments = ""
    i = 0
    conditions_array.each do |key, val|
      # combine search terms together
      arguments += key
      arguments += " AND " if i < conditions_array.length - 1

      # build list of search values
      conditions << val

      i += 1
    end
    # prepend conditions array with argument string
    conditions.unshift(arguments)
    return conditions
  end

  def create_info_table
    info = MemberInfo.new
    info.user_id = self.id
    info.save
  end

  def self.convert_month(num)
    months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    return months[num.to_i]
  end
end
