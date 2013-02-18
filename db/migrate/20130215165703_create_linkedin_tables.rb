class CreateLinkedinTables < ActiveRecord::Migration
  def change
  	create_table :linkedin_infos, force: true do |t|
  		t.integer :user_id
      t.integer :basic_token_id
      t.integer :basic_email_token_id
      t.integer :full_token_id
      t.integer :invite_token_id
  	end

    create_table :linkedin_tokens, force: true do |t|
      t.integer :linkedin_info_id
      t.string :permissions
      t.string :access_token
      t.string :access_secret
      t.datetime :last_updated
    end
  end
end
