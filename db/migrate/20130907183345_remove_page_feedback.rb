class RemovePageFeedback < ActiveRecord::Migration
  def up
    drop_table :page_feedbacks
  end

  def down
    raise ActiveRecord::IreversibleMigration
    #This could instead include the code to create the endorsement table if one needs it.  However, that would be quite a bit of effort.
    #See: http://stackoverflow.com/questions/4020131/rails-db-migration-how-to-drop-a-table
  end
end
