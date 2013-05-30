class AddAgeToCoachingRequest < ActiveRecord::Migration
  def change
    add_column :coaching_requests, :age, :integer
  end
end
