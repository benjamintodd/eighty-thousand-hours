class AddWritingTimeToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :writing_time, :integer
  end
end
