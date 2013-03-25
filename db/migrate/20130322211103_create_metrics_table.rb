class CreateMetricsTable < ActiveRecord::Migration
  def change
  	create_table :weekly_metrics, force: true do |t|
      t.datetime :date
      t.float :average_profile_completeness
      t.float :median_donation_percentage
      t.float :donation_optin_percentage
      t.float :avatar_percentage
      t.float :avatar_percentage_new_users
  	end

  	create_table :monthly_metrics, force: true do |t|
      t.datetime :date
      t.float :average_profile_completeness
      t.float :median_donation_percentage
      t.float :donation_optin_percentage
      t.float :avatar_percentage
      t.float :avatar_percentage_new_users
  	end
  end
end
