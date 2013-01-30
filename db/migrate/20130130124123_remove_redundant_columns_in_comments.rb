class RemoveRedundantColumnsInComments < ActiveRecord::Migration
  def up
  	remove_column :comments, :blog_post_id
  	remove_column :comments, :discussion_post_id
  end

  def down
  	add_column :comments, :blog_post_id, :integer
  	add_column :comments, :discussion_post_id, :integer
  end
end
