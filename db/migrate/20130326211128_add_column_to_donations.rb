class AddColumnToDonations < ActiveRecord::Migration
  def change
  	add_column :donations, :inspired_by_cea, :boolean, default: false
  end
end
