class ChangePublishedAtToDatetime < ActiveRecord::Migration
  def change
    change_column :blog_posts, :published_at, :datetime
  end
end
