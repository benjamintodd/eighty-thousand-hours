class AddAttributionToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :image_attribution, :text
  end
end
