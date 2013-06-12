ActiveAdmin.register PageFeedback do
  menu :if => proc{ can?(:manage, PageFeedback) },
       :label => "Page Feedback"
  controller.authorize_resource

  index do
    column :page
    column :rating
    column :comments
    default_actions
  end
end
