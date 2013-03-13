class AddProfileCompletenessColumnToProfiles < ActiveRecord::Migration
  def change
  	add_column :etkh_profiles, :completeness_score, :integer, default: 0
  end
end
