class AddPostColumnsToVotes < ActiveRecord::Migration
  def up
  	add_column :votes, :post_id, :integer
  	add_column :votes, :post_type, :string
  	add_index :votes, [:post_id, :post_type]
  end

  def down
  	remove_column :votes, :post_id
  	remove_column :votes, :post_type
  end
end
