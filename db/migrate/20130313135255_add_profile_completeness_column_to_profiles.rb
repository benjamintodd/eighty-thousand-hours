class AddProfileCompletenessColumnToProfiles < ActiveRecord::Migration
  def change
  	add_column :etkh_profiles, :completeness_score, :integer
  end
end
