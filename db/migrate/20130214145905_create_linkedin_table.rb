class CreateLinkedinTable < ActiveRecord::Migration
  def change
    create_table "linkedin_infos", force: true, id: false do |t|
      t.integer :user_id
      t.string :permissions
      t.string :access_token
      t.string :access_secret
      t.datetime :last_updated
    end
  end
end
