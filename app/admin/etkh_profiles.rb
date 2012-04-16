ActiveAdmin.register EtkhProfile do
  menu :if => proc{ can?(:manage, EtkhProfile) },
       :label => "80k Profiles",
       :parent => "Members"
  controller.authorize_resource

  index do
    column :id
    column :name do |p|
      p.user.name
    end
    column :occupation
    column :career_plans

    default_actions
  end
end