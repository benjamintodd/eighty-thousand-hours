class CreateCoachingRequests < ActiveRecord::Migration
  def change
    create_table :coaching_requests do |t|
      t.string :name
      t.string :email
      t.string :skype
      t.string :current_situation
      t.string :wants_better_world
      t.string :dont_know_options
      t.string :cant_decide
      t.string :other_factors
      t.text :current_career_plans
      t.text :conterfactual_career_plans
      t.integer :current_donation_percent
      t.string :current_donation_target
      t.integer :counterfactual_donation_amount
      t.string :counterfactual_donation_target
      t.text :questions

      t.timestamps
    end
  end
end
