class AddAgeToMemberInfo < ActiveRecord::Migration
  def change
  	add_column :member_infos, :age, :integer
  	add_column :member_infos, :age_updated_at, :datetime
  end
end
