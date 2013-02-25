class ChangeEtkhProfiles < ActiveRecord::Migration
  def change
  	add_column :etkh_profiles, :career_sector, :string

  	create_table :positions, id: false do |t|
      t.integer :etkh_profile_id 
      t.string :position
      t.string :organisation
      t.datetime :start_date
      t.datetime :end_date
  	end

    create_table :educations, id: false do |t|
      t.integer :etkh_profile_id
      t.string :university
      t.string :course
      t.string :qualification
      t.datetime :start_date
      t.datetime :end_date
    end
  end
end
