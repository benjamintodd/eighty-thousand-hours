class AddLinkedinColumnToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :linkedin_signup, :boolean, default: false
  	add_column :users, :linkedin_email, :string
  end
end
