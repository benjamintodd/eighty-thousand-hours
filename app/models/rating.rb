class Rating < ActiveRecord::Base
  CATEGORIES = %w(overall original practical persuasive transparent accessible engaging)
  belongs_to :blog_post
  belongs_to :user
  attr_accessible :overall, :original, :practical, :persuasive,:transparent, :accessible, :engaging, :user, :user_id, :blog_post, :blog_post_id
  validates :user, presence: true
  validates :blog_post, presence: true
  validates :overall, :original, :practical, :persuasive, :transparent, :accessible, :engaging, inclusion: { in: (0..10)}

  validates :blog_post_id, :uniqueness => {:scope => :user_id}

  def total
    original + practical + persuasive + transparent + accessible + engaging
  end
end
