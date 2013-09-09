ActiveAdmin.register Cause do
  menu :if => proc{ can?(:manage, Cause) }

  index do
    column :name
    column :created_at
    default_actions
  end
end
