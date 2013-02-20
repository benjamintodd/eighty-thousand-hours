class AddLinkedinColumnToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :linkedin_signup, :boolean, default: false
  end
end
