ActiveAdmin.register Rating do
  menu :if => proc{ can?(:read, Rating) }
  controller.authorize_resource

  index do
    column :blog_post
    column :user
    column :overall
    column :average
    column :original
    column :practical
    column :transparent
    column :persuasive
    column :accessible
    column :engaging
    column :created_at
    default_actions
  end

  show do |rating|
    attributes_table do
      row :blog_post
      row :user
      row :overall
      row :average
      row :original
      row :practical
      row :transparent
      row :persuasive
      row :accessible
      row :engaging
      row :created_at
      row :comment
      row :comment
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :overall
      f.input :original
      f.input :practical
      f.input :transparent
      f.input :persuasive
      f.input :accessible
      f.input :engaging
      f.input :comment
      f.input :rubric_comment
      f.buttons
    end
  end

end
