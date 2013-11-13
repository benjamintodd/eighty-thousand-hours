class AddPublishedAtToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :published_at, :date
    change_column_default :blog_posts, :draft, true
  end
end
