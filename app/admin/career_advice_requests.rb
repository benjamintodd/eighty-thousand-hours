ActiveAdmin.register CareerAdviceRequest do
  menu :if => proc{ can?(:manage, CareerAdviceRequest) }

  index do
    column :name
    column :email
    column :created_at
    default_actions
  end
end
