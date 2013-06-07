class PageFeedback < ActiveRecord::Base
  belongs_to :page
  attr_accessible :comments, :rating
end
