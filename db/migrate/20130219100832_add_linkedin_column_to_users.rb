class AddLinkedinColumnToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :linkedin_connection, :boolean, default: false
  end
end
