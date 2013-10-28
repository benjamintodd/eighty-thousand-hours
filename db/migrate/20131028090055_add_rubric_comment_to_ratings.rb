class AddRubricCommentToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :rubric_comment, :text
  end
end
