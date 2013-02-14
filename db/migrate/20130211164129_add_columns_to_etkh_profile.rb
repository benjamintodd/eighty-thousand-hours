class AddColumnsToEtkhProfile < ActiveRecord::Migration
  def up
  	add_column :etkh_profiles, :profile_completeness, :integer
  end

  def down
  	remove_column :etkh_profiles, :profile_completeness
  end
end
