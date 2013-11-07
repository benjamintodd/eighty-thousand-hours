class Rating < ActiveRecord::Base
  CATEGORIES = %w(overall practical original transparent persuasive accessible engaging)
  belongs_to :blog_post
  belongs_to :user
  attr_accessible :overall, :original, :practical, :transparent, :persuasive, :accessible, :engaging, :comment, :rubric_comment, :user, :user_id, :blog_post, :blog_post_id
  validates :user, presence: true
  validates :blog_post, presence: true
  validates :overall, :original, :practical, :persuasive, :transparent, :accessible, :engaging, inclusion: { in: (1..5)}

  validates :blog_post_id, :uniqueness => {:scope => :user_id}

  def total
    original + practical + persuasive + transparent + accessible + engaging
  end

  def average
    (total.to_f / 6).round(1)
  end
end
