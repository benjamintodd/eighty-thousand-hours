# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130825114828) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.string   "namespace"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "attached_images", :force => true do |t|
    t.integer  "blog_post_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attached_images", ["blog_post_id"], :name => "index_attached_images_on_blog_post_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.boolean  "draft",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attribution"
    t.string   "slug"
    t.text     "teaser"
    t.string   "author"
    t.integer  "facebook_likes", :default => 0
    t.integer  "user_id"
    t.string   "category",       :default => "discussion"
  end

  add_index "blog_posts", ["created_at"], :name => "index_blog_posts_on_created_at"
  add_index "blog_posts", ["slug"], :name => "index_posts_on_slug", :unique => true
  add_index "blog_posts", ["user_id"], :name => "index_blog_posts_on_user_id"

  create_table "career_advice_requests", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "skype"
    t.text     "background"
    t.text     "thoughts"
    t.text     "questions"
    t.boolean  "mailing_list"
    t.string   "cv_filename"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "causes", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
  end

  add_index "causes", ["slug"], :name => "index_charities_on_slug", :unique => true

  create_table "coaching_requests", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "skype"
    t.string   "current_situation"
    t.string   "wants_better_world"
    t.string   "dont_know_options"
    t.string   "cant_decide"
    t.string   "other_factors"
    t.text     "current_career_plans"
    t.text     "conterfactual_career_plans"
    t.integer  "current_donation_percent"
    t.string   "current_donation_target"
    t.integer  "counterfactual_donation_amount"
    t.string   "counterfactual_donation_target"
    t.text     "questions"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "age"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "email"
    t.integer  "commentable_id"
    t.string   "commentable_type"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "discussion_posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.boolean  "draft",      :default => false
    t.integer  "user_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discussion_posts", ["slug"], :name => "index_discussion_posts_on_slug", :unique => true
  add_index "discussion_posts", ["user_id"], :name => "index_discussion_posts_on_user_id"

  create_table "donations", :force => true do |t|
    t.integer  "amount_cents",         :default => 0
    t.integer  "cause_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "receipt_file_name"
    t.string   "receipt_content_type"
    t.integer  "receipt_file_size"
    t.datetime "receipt_updated_at"
    t.boolean  "confirmed",            :default => false
    t.boolean  "public",               :default => true
    t.boolean  "public_amount",        :default => false
    t.date     "date"
    t.string   "currency"
    t.boolean  "inspired_by_cea"
  end

  add_index "donations", ["cause_id"], :name => "index_donations_on_charity_id"
  add_index "donations", ["user_id"], :name => "index_donations_on_user_id"

  create_table "educations", :force => true do |t|
    t.integer "etkh_profile_id"
    t.integer "member_info_id"
    t.string  "university"
    t.string  "course"
    t.string  "qualification"
    t.integer "start_date_year"
    t.integer "end_date_year"
    t.boolean "current_education"
  end

  add_index "educations", ["etkh_profile_id"], :name => "index_educations_on_etkh_profile_id"
  add_index "educations", ["member_info_id"], :name => "index_educations_on_member_info_id"

  create_table "endorsements", :force => true do |t|
    t.string   "author"
    t.string   "position"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "header",           :default => false
    t.boolean  "endorsement_page", :default => true
    t.integer  "weight",           :default => 1
  end

  create_table "etkh_profiles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "background"
    t.string   "organisation"
    t.boolean  "public_profile",             :default => true
    t.text     "skills_knowledge_share"
    t.text     "skills_knowledge_learn"
    t.integer  "user_id"
    t.text     "causes_comment"
    t.text     "activities_comment"
    t.integer  "donation_percentage",        :default => 30
    t.boolean  "donation_percentage_optout", :default => true
    t.string   "career_sector"
    t.string   "current_position"
    t.integer  "completeness_score",         :default => 0
    t.integer  "admin_rating",               :default => 0
    t.boolean  "display_email",              :default => true
  end

  add_index "etkh_profiles", ["user_id"], :name => "index_etkh_profiles_on_user_id", :unique => true

  create_table "etkh_profiles_profile_option_activities", :id => false, :force => true do |t|
    t.integer "etkh_profile_id"
    t.integer "profile_option_activity_id"
  end

  add_index "etkh_profiles_profile_option_activities", ["etkh_profile_id"], :name => "index_profile_option_activities_on_etkh_profile_id"

  create_table "etkh_profiles_profile_option_causes", :id => false, :force => true do |t|
    t.integer "etkh_profile_id"
    t.integer "profile_option_cause_id"
  end

  add_index "etkh_profiles_profile_option_causes", ["etkh_profile_id"], :name => "index_profile_option_causes_on_etkh_profile_id"

  create_table "linkedin_infos", :force => true do |t|
    t.integer  "user_id"
    t.string   "permissions"
    t.string   "access_token"
    t.string   "access_secret"
    t.datetime "last_updated"
  end

  add_index "linkedin_infos", ["user_id"], :name => "index_linkedin_infos_on_user_id", :unique => true

  create_table "member_infos", :force => true do |t|
    t.integer  "user_id"
    t.datetime "DOB"
    t.string   "gender"
    t.integer  "age"
    t.datetime "age_updated_at"
  end

  add_index "member_infos", ["user_id"], :name => "index_member_infos_on_user_id", :unique => true

  create_table "monthly_metrics", :force => true do |t|
    t.datetime "date"
    t.float    "average_profile_completeness"
    t.float    "median_donation_percentage"
    t.float    "donation_optin_percentage"
    t.float    "avatar_percentage"
    t.float    "avatar_percentage_new_users"
    t.integer  "number_users_tracking_donations"
    t.float    "total_donations"
  end

  create_table "page_feedbacks", :force => true do |t|
    t.string   "rating"
    t.text     "comments"
    t.integer  "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "video_id"
    t.integer  "user_id"
  end

  add_index "page_feedbacks", ["page_id"], :name => "index_page_feedbacks_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_box",               :default => true
    t.string   "header_title"
    t.boolean  "menu_top_level",         :default => false
    t.boolean  "menu_display",           :default => true
    t.integer  "menu_priority",          :default => 0
    t.boolean  "just_a_link",            :default => false
    t.integer  "parent_id"
    t.boolean  "menu_display_in_footer", :default => true
    t.boolean  "menu_sidebar",           :default => false
  end

  add_index "pages", ["slug"], :name => "index_pages_on_slug", :unique => true

  create_table "positions", :force => true do |t|
    t.integer "etkh_profile_id"
    t.integer "member_info_id"
    t.string  "position"
    t.string  "organisation"
    t.string  "start_date_month"
    t.integer "start_date_year"
    t.string  "end_date_month"
    t.integer "end_date_year"
    t.boolean "current_position"
  end

  add_index "positions", ["etkh_profile_id"], :name => "index_positions_on_etkh_profile_id"
  add_index "positions", ["member_info_id"], :name => "index_positions_on_member_info_id"

  create_table "profile_option_activities", :force => true do |t|
    t.string "title"
  end

  create_table "profile_option_causes", :force => true do |t|
    t.string "title"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "supporters", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "dont_email_me"
    t.boolean  "anonymous"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supporters", ["email"], :name => "index_supporters_on_email", :unique => true

  create_table "surveys", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.string   "url"
    t.string   "name_box"
    t.string   "email_box"
    t.string   "id_box"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "surveys", ["slug"], :name => "index_surveys_on_slug", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",           :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                               :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "slug"
    t.string   "location"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "phone"
    t.string   "external_twitter"
    t.string   "external_facebook"
    t.string   "external_linkedin"
    t.string   "real_name"
    t.string   "external_website"
    t.boolean  "omniauth_signup",                             :default => false
    t.boolean  "notifications_on_forum_posts",                :default => true
    t.boolean  "notifications_on_comments",                   :default => true
    t.string   "linkedin_email"
    t.string   "avatar_remote_url"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "positive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "post_id"
    t.string   "post_type"
  end

  add_index "votes", ["post_id", "post_type"], :name => "index_votes_on_post_id_and_post_type"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

  create_table "weekly_metrics", :force => true do |t|
    t.datetime "date"
    t.float    "average_profile_completeness"
    t.float    "median_donation_percentage"
    t.float    "donation_optin_percentage"
    t.float    "avatar_percentage"
    t.float    "avatar_percentage_new_users"
  end

end
