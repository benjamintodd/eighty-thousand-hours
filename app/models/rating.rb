class Rating < ActiveRecord::Base
  belongs_to :blog_post
  belongs_to :user
  attr_accessible :overall, :original, :practical, :persuasive,:transparent, :accessible, :engaging, :user, :blog_post, :blog_post_id
end
