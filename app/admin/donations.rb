ActiveAdmin.register Donation do
  menu :if => proc{ can?(:manage, Donation) }
end