class AddEmailNotificationsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :notifications_on_forum_posts, :boolean, default: true
  	add_column :users, :notifications_on_comments, :boolean, default: true
  end
end
