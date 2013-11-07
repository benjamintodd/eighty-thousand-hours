class AddPrivacyToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :privacy, :boolean
  end
end
