class CreatePageFeedbacks < ActiveRecord::Migration
  def change
    create_table :page_feedbacks do |t|
      t.string :rating
      t.text :comments
      t.references :page

      t.timestamps
    end
    add_index :page_feedbacks, :page_id
  end
end
