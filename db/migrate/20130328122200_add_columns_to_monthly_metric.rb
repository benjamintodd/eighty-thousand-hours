class AddColumnsToMonthlyMetric < ActiveRecord::Migration
  def change
  	add_column :monthly_metrics, :number_users_tracking_donations, :integer
  	add_column :monthly_metrics, :total_donations, :float
  end
end
