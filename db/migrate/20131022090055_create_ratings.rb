class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :overall
      t.integer :original
      t.integer :practical
      t.integer :persuasive
      t.integer :transparent
      t.integer :accessible
      t.integer :engaging
      t.references :user
      t.references :blog_post
      t.timestamps
    end
  end
end
