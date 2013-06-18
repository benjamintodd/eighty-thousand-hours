ActiveAdmin.register PageFeedback do
  menu :if => proc{ can?(:manage, PageFeedback) },
       :label => "Page Feedback"
  controller.authorize_resource

  index do
    column :page
    column :video_id
    column :rating
    column :comments
    column :user
    default_actions
  end
end
