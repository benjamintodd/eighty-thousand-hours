class AddCommentableColumnsToComments < ActiveRecord::Migration
  def up
  	add_column :comments, :commentable_id, :integer
  	add_column :comments, :commentable_type, :string
  	add_index :comments, [:commentable_id, :commentable_type]
  end

  def down
  	remove_column :comments, :commentable_id
  	remove_column :comments, :commentable_type
  	#remove_index :comments, name: "index_comments_on_commentable_id_and_commentable_type"
  end
end
