class AddRatingToProfiles < ActiveRecord::Migration
  def change
  	add_column :etkh_profiles, :admin_rating, :integer, default: 0
  end
end
