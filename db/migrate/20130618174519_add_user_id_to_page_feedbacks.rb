class AddUserIdToPageFeedbacks < ActiveRecord::Migration
  def change
    add_column :page_feedbacks, :user_id, :integer
  end
end
