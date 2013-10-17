# a comment can either belong to a blog post, a discussion post or 
# another comment. These are each of type commentable.

class Comment < ActiveRecord::Base
  validates_presence_of :body,    message: "can't be blank"

  # should check we have either blog_post_id *OR* discussion_post_id
  #validates_presence_of :post_id

  attr_accessor :email_confirmation

  before_save :check_valid
  before_validation :check_honeypot

  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable
  has_many :votes, :as => :post, :dependent => :destroy

  scope :blog, where(:blog_post_id != nil)

  def get_name
    user ? user.name : name
  end

  def post_author_email
    if self.commentable_type == "DiscussionPost"
      self.commentable.user.email
    elsif self.commentable_type == "BlogPost"
      if self.commentable.user
        self.commentable.user.email
      else
        # blog post is by guest w. no email
        nil
      end
    elsif self.commentable_type == "Comment"
      self.email
    else
      nil
    end
  end

  def net_votes
    self.votes.upvotes.size - self.votes.downvotes.size
  end


  ## methods related to nested comments

  # finds the blog or discussion post under which the comment has been posted
  def get_post
    if self.commentable_type == "BlogPost" || self.commentable_type == "DiscussionPost"
      self.commentable
    else  #must be a nested comment
      # loop through parents until post is reached
      parent = Comment.find_by_id(self.commentable_id)
      while parent.commentable_type != "BlogPost" && parent.commentable_type != "DiscussionPost"
        parent = Comment.find_by_id(parent.commentable_id)
      end
      parent.commentable
    end
  end

  # finds the top comment in the hierarchy of nested comments
  def get_top_parent_comment
    if self.commentable_type == "BlogPost" || self.commentable_type == "DiscussionPost"
      self
    else  #must be a nested comment
      # loop through parents until top comment is reached
      parent = Comment.find_by_id(self.commentable_id)
      while parent.commentable_type != "BlogPost" && parent.commentable_type != "DiscussionPost"
        parent = Comment.find_by_id(parent.commentable_id)
      end
      parent
    end
  end

  # determines the nested level of this comment
  # level 0 denotes a non-nested comment
  def get_depth
    if self.commentable_type == "BlogPost" || self.commentable_type == "DiscussionPost"
      return 0
    else  # must be a nested comment
      # loop through parents and count number of nested levels
      count = 1
      parent = Comment.find_by_id(self.commentable_id)
      while parent.commentable_type != "BlogPost" && parent.commentable_type != "DiscussionPost"
        parent = Comment.find_by_id(parent.commentable_id)
        count+=1
      end
      return count
    end
  end


  private

  def check_honeypot
    email_confirmation.blank?
  end

  def check_valid
    result = true
    if self.user.nil?
      if self.name.blank?
        errors.add(:name, "can't be blank" )
        result = false
      end
      if self.email.blank?
        errors.add(:email, "can't be blank" )
        result = false
      end
    end

    # also check that it has an id of something of type commentable
    if self.commentable_id.nil?
      result = false
    end

    result
  end
end
