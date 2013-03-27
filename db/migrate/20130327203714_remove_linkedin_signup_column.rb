class RemoveLinkedinSignupColumn < ActiveRecord::Migration
  def change
  	remove_column :users, :linkedin_signup
  end
end
