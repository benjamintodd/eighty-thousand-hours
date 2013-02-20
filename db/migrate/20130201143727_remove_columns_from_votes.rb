class RemoveColumnsFromVotes < ActiveRecord::Migration
  def up
  	remove_column :votes, :blog_post_id
  	remove_column :votes, :discussion_post_id
  end

  def down
  	add_column :votes, :blog_post_id, :integer
  	add_column :votes, :discussion_post_id, :integer
  end
end
