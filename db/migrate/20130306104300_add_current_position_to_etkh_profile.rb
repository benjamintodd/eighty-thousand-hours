class AddCurrentPositionToEtkhProfile < ActiveRecord::Migration
  def change
  	add_column :etkh_profiles, :current_position, :string
  end
end
