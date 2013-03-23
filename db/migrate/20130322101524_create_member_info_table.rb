class CreateMemberInfoTable < ActiveRecord::Migration
  def change
  	create_table :member_infos, force: true do |t|
      t.integer :user_id
      t.datetime :DOB
      t.string :gender
  	end
  end
end
