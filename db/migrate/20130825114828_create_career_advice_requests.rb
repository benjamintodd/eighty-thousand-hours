class CreateCareerAdviceRequests < ActiveRecord::Migration
  def change
    create_table :career_advice_requests do |t|
      t.string :name
      t.string :email
      t.string :skype
      t.text :background
      t.text :thoughts
      t.text :questions
      t.boolean :mailing_list
      t.string :cv_filename

      t.timestamps
    end
  end
end
