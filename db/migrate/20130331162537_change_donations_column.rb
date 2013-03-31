class ChangeDonationsColumn < ActiveRecord::Migration
  def change
  	remove_column :donations, :inspired_by_cea
  	add_column :donations, :inspired_by_cea, :boolean
  end
end
