class AddDisplayEmailToProfiles < ActiveRecord::Migration
  def change
  	add_column :etkh_profiles, :display_email, :boolean, default: true
  end
end
