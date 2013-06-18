class PageFeedback < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  attr_accessible :comments, :rating, :video_id
end
