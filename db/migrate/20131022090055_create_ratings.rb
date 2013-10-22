class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :overall
      t.references :user
      t.references :blog_post
      t.timestamps
    end
  end
end
