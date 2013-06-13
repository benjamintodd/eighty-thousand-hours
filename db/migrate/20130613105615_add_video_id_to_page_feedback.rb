class AddVideoIdToPageFeedback < ActiveRecord::Migration
  def change
    add_column :page_feedbacks, :video_id, :integer
  end
end
