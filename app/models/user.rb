class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  # votes are independent from users so destroy associated votes here
  before_destroy { |user| Vote.destroy_all "user_id = #{user.id}" }

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

  # omniauth authentication
  has_many :authentications, :dependent => :destroy

  # comments on posts
  has_many :comments, :dependent => :destroy

  # dependent means 80k profile gets destroyed when user is destroyed
  has_one :etkh_profile, :dependent => :destroy
  accepts_nested_attributes_for :etkh_profile
  before_create :build_default_profile

  # a user can write many blog posts
  has_many :blog_posts

  # a user can write many discussion posts
  has_many :discussion_posts

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


  # e.g. Admin, BlogAdmin, WebAdmin
  has_and_belongs_to_many :roles
  
  # a User can have a TeamRole (e.g. Events, Communications)
  belongs_to :team_role

  # a User can create lots of donations
  has_many :donations

  # a User can vote on lots of posts
  has_many :votes

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
    columns = ["id", "name", "email", "sign_in_count", "last_sign_in_at", "created_at", "location", "organisation", "background", "skills_knowledge_share", "skills_knowledge_learn", "donation_percentage", "donation_percentage_optout", "external twitter", "external facebook", "external_linkedin", "external_website"]
    CSV.generate(options) do |csv|
      csv << columns
      self.all.each do |user|
        if user.etkh_profile
          entries = [user.id, user.name, user.email, user.sign_in_count, user.last_sign_in_at, user.created_at, user.location, user.etkh_profile.organisation, user.etkh_profile.background, user.etkh_profile.skills_knowledge_share, user.etkh_profile.skills_knowledge_learn, user.etkh_profile.donation_percentage, user.etkh_profile.donation_percentage_optout, user.external_twitter, user.external_linkedin, user.external_website]
        else
          entries = [user.id, user.name, user.email, user.sign_in_count, user.last_sign_in_at, user.created_at, user.location, nil, nil, nil, nil, nil, user.external_twitter, user.external_linkedin, user.external_website]
        end
        csv << entries
      end
    end
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

    # find common elements in both results arrays
    return user_results & user_profile_results
  end

  ### Karma score ###
  # define variable weights
  BLOG_POST_CREATED         = 15
  DISCUSSION_POST_CREATED   = 10
  BLOG_POST_COMMENT         = 5  # comments user has made
  DISCUSSION_POST_COMMENT   = 5  # ditto
  BLOG_POST_UPVOTE          = 3  # upvotes of user's blog posts
  BLOG_POST_FBLIKE          = 2  # etc
  DISCUSSSION_POST_UPVOTE   = 3
  COMMENT_UPVOTE            = 3
  BLOG_POST_DOWNVOTE        = BLOG_POST_UPVOTE
  DISCUSSION_POST_DOWNVOTE  = DISCUSSSION_POST_UPVOTE
  COMMENT_DOWNVOTE          = COMMENT_UPVOTE

  # method to calculate user's karma score
  def get_karma_score
    # posts created
    n_blog_posts = self.blog_posts.length
    score = n_blog_posts * BLOG_POST_CREATED

    n_discus_posts = self.discussion_posts.length
    score += n_discus_posts * DISCUSSION_POST_CREATED

    # comments
    n_blog_comments = 0
    n_discus_comments = 0
    n_upvotes_comment = 0
    n_downvotes_comment = 0
    self.comments.each do |comment|
      # comments posted
      if comment.get_post.instance_of?(BlogPost) 
        n_blog_comments += 1
      elsif comment.get_post.instance_of?(DiscussionPost) 
        n_discus_comments += 1
      end

      # comments up or down voted
      comment.votes.each do |vote|
        if vote.positive == true
          n_upvotes_comment += 1
        else
          n_downvotes_comment += 1
        end
      end
    end
    score += n_blog_comments * BLOG_POST_COMMENT
    score += n_discus_comments * DISCUSSION_POST_COMMENT
    score += n_upvotes_comment * COMMENT_UPVOTE
    score -= n_downvotes_comment * COMMENT_DOWNVOTE

    # blog post votes
    n_upvotes_blog = 0
    n_downvotes_blog = 0
    self.blog_posts.each do |post|
      post.votes.each do |vote|
        if vote.positive == true
          n_upvotes_blog += 1
        else
          n_downvotes_blog += 1
        end
      end
      score += post.facebook_likes * BLOG_POST_FBLIKE
    end
    score += n_upvotes_blog * BLOG_POST_UPVOTE
    score -= n_downvotes_blog * BLOG_POST_DOWNVOTE
    
    # discussion post votes
    n_upvotes_discus = 0
    n_downvotes_discus = 0
    self.discussion_posts.each do |post|
      post.votes.each do |vote|
        if vote.positive == true
          n_upvotes_discus += 1
        else
          n_downvotes_discus += 1
        end
      end
    end
    score += n_upvotes_discus * DISCUSSSION_POST_UPVOTE
    score -= n_downvotes_discus * DISCUSSION_POST_DOWNVOTE

    return score
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
end
