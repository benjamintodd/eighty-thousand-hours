class BlogPost < ActiveRecord::Base
  TYPES = %w(Case\ Studies Interviews How\ To Discussion Research\ Findings Updates)
  CATEGORIES = %w(Entrepreneurship Medecine Research Finance Software Engineering Law Consulting)

  include Rails.application.routes.url_helpers
  extend FriendlyId
  friendly_id :title, :use => :slugged

  # for versioning with paper_trail
  has_paper_trail  #depreciated?

  # Alias for <tt>acts_as_taggable_on :tags</tt>:
  acts_as_taggable
  acts_as_taggable_on :types, :categories

  scope :draft,     where(:draft => true).order("created_at DESC")
  scope :published, where(:draft => false).order("created_at DESC")

  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :teaser

  def self.get_types
    TYPES
  end

  def self.get_categories
    CATEGORIES
  end

  def self.by_votes( n = BlogPost.all.size )
    n = 1 if n < 1
    where(:draft => false).sort_by{|p| p.net_votes}.reverse.slice(0..(n-1))
  end

  def self.recent(n)
    BlogPost.first(n)
  end

  def self.by_popularity( n = BlogPost.all.size )
    n = 1 if n < 1
    where(:draft => false).sort_by{|p| p.popularity}.reverse.slice(0..(n-1))
  end

  def self.by_author( author, page )
    # see if we have a user with this name
    user = User.find_by_name( author )
    if user
      query = BlogPost.published.where("user_id = ?", user.id ).order("created_at DESC")
    else
      query = BlogPost.published.where("author = ?", author ).order("created_at DESC")
    end

    query.paginate(:page => page, :per_page => 10)
  end

  def self.by_author_drafts( user_id )
    user = User.find( user_id )
    query = BlogPost.draft.where("user_id = ?", user.id ).order("created_at DESC")
  end

  def self.author_list
    authors = where(:draft => false).where("author IS NOT NULL").select('DISTINCT author').map{|p| p.author}
    users   = where(:draft => false).where("user_id IS NOT NULL").select('DISTINCT user_id').map{|p| p.user.name}

    (authors + users).sort
  end

  # a User wrote this post
  belongs_to :user

  #can have ratings
  has_many :ratings, :dependent => :destroy
  has_many :raters, through: :ratings, uniq: true, :source => :user
  #
  # can have many uploaded images
  has_many :attached_images, :dependent => :destroy
  attr_accessible :title, :body, :teaser, :user_id, :draft, :attached_images_attributes, :tag_list, :type_list, :category_list, :author, :attribution, :created_at
  accepts_nested_attributes_for :attached_images, :allow_destroy => true 


  #for rating average
  def average_rating(attribute)
    ratings.average(attribute).to_f.round(1)
  end

  def total_average_rating
    total = %w(original practical persuasive transparent accessible engaging).inject(0){|result, element| result + average_rating(element)}
    (total / 6).round(1)
  end

  # override to_param to specify format of URL
  # now we can call post_path(@post) and get
  # "/blog/8-today-show" returned for example
  def to_param
    "#{self.id}-#{self.friendly_id}"
  end

  def net_votes
    self.facebook_likes
  end

  def popularity
    # magic scaling factors in here...
    fb_votes = self.facebook_likes * 1.0/(1 + (DateTime.now - self.created_at.to_datetime).to_i)
  end

  # first bit of the article -- used as
  # opengraph description, and on index page
  def get_teaser
    return self.teaser if self.teaser?

    # if post doesn't have a defined teaser then we try
    # to create one by grabbing the first couple of sentences

    # note that this fails in a lot of edge cases
    # http://stackoverflow.com/questions/1714657/find-some-sentences
    # failure cases so far:
    #   * sentence ends with ?
    #   * sentence contains URL www.blah.com
    #   * markdown should be stripped out
    sentences = self.body.split(".")
    if sentences.size >= 2
      sentences[0] + ". " + sentences[1] + "..."
    else
      return self.body
    end
  end

  # this is called by Heroku scheduler on a regular basis
  def self.update_facebook_likes
    BlogPost.all.each do |p|
      num_likes = get_facebook_likes p
      p.facebook_likes = num_likes
      p.save
    end
  end

  # for active admin dashboard
  def admin_permalink
    admin_post_path(self)
  end

  def url
    "http://80000hours.org/blog/#{id}-#{slug}"
  end

  private

  def self.http_get(domain,path,params)
    path = unless params.empty?
             path + "?" + params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
           else
             path
           end
    request = Net::HTTP.get(domain, path)
  end

  def self.get_facebook_likes(post)
    params = {
      :query => 'SELECT like_count, share_count FROM link_stat WHERE url = "http://80000hours.org' + "/blog/#{post.id}-#{post.slug}"+ '"',
      :format => 'json'
    }

    http = http_get('api.facebook.com', '/method/fql.query', params)
    like_count = JSON.parse(http)[0]["like_count"]
    share_count = JSON.parse(http)[0]["share_count"]
    result = like_count + share_count
  end

end
