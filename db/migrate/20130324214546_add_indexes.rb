class AddIndexes < ActiveRecord::Migration
  def change
  	add_index :attached_images, :blog_post_id, name: "index_attached_images_on_blog_post_id"
  	add_index :authentications, :user_id, name: "index_authentications_on_user_id"
  	add_index :blog_posts, :user_id, name: "index_blog_posts_on_user_id"
  	add_index :blog_posts, :created_at, name: "index_blog_posts_on_created_at"
  	add_index :comments, :user_id, name: "index_comments_on_user_id"
  	add_index :discussion_posts, :user_id, name: "index_discussion_posts_on_user_id"
  	add_index :donations, :user_id, name: "index_donations_on_user_id"
  	add_index :educations, :etkh_profile_id, name: "index_educations_on_etkh_profile_id"
  	add_index :educations, :member_info_id, name: "index_educations_on_member_info_id"
  	add_index :etkh_profiles, :user_id, name: "index_etkh_profiles_on_user_id", unique: true
  	add_index :etkh_profiles_profile_option_activities, :etkh_profile_id, name: "index_etkh_profiles_profile_option_activities_on_etkh_profile_id"
  	add_index :etkh_profiles_profile_option_causes, :etkh_profile_id, name: "index_etkh_profiles_profile_option_causes_on_etkh_profile_id"
  	add_index :linkedin_infos, :user_id, name: "index_linkedin_infos_on_user_id", unique: true
  	add_index :member_infos, :user_id, name: "index_member_infos_on_user_id"
  	add_index :positions, :etkh_profile_id, name: "index_positions_on_etkh_profile_id"
  	add_index :positions, :member_info_id, name: "index_positions_on_member_info_id", unique: true
  	add_index :votes, :user_id, name: "index_votes_on_user_id"
  end
end
