##Models and Schema

![DB Schema](schema.png)

ActiveAdminComment
: Part of ActiveAdmin
: Columns : author_id, author_type, body, created_at, id, namespace, resource_id, resource_type, updated_at

AttachedImage
: Columns : blog_post_id, created_at, id, image_content_type,
image_file_name, image_file_size, image_updated_at, updated_at
: Belongs to : blog_post

Authentication
: Columns : created_at, id, provider, uid, updated_at, user_id
: Belongs to : user

BlogPost
: Columns : attribution, author, body, category, created_at, draft, facebook_likes, id, slug, teaser, title, updated_at, user_id
: Belongs to : user
: Has many : attached_images

Cause
: Columns : created_at, description, id, name, slug, updated_at, website
: Has many : donations

ChatRequest
: This only exists to send an email.  It does not exist in the database.

CoachingRequest
: Columns : age, cant_decide, conterfactual_career_plans, counterfactual_donation_amount, counterfactual_donation_target, created_at, current_career_plans, current_donation_percent, current_donation_target, current_situation, dont_know_options, email, id, name, other_factors, questions, skype, updated_at, wants_better_world

Comment
: Columns : body, commentable_id, commentable_type, created_at, email, id, name, updated_at, user_id
: Belongs to : user

DiscussionPost
: Columns : body, created_at, draft, id, slug, title, updated_at, user_id
Belongs to : user

Donation
: Columns : amount_cents, cause_id, confirmed, created_at, currency, date, id, inspired_by_cea, public, public_amount, receipt_content_type, receipt_file_name, receipt_file_size, receipt_updated_at, updated_at, user_id
: Belongs to : cause , user

Education
: Columns : course, current_education, end_date_year, etkh_profile_id, id, member_info_id, qualification, start_date_year, university
: Belongs to : etkh_profile , member_info

Endorsement
: Columns : author, body, created_at, endorsement_page, header, id, position, updated_at, weight

EtkhApplication
: This does not exist in the database, nor the controller.  Does have a
model.

EtkhProfile
: Columns : activities_comment, admin_rating, background, career_sector, causes_comment, completeness_score, created_at, current_position, display_email, donation_percentage, donation_percentage_optout, id, organisation, public_profile, skills_knowledge_learn, skills_knowledge_share, updated_at, user_id
: Belongs to : user
: Has many : educations , etkh_profiles_profile_option_activities , etkh_profiles_profile_option_causes , positions

EtkhProfilesProfileOptionActivity
: Join table, not a model.
: Columns : etkh_profile_id, profile_option_activity_id
: Belongs to : etkh_profile , profile_option_activity

EtkhProfilesProfileOptionCause
: Join table, not a model.
: Columns : etkh_profile_id, profile_option_cause_id
: Belongs to : etkh_profile , profile_option_cause

LinkedinInfo
: Columns : access_secret, access_token, id, last_updated, permissions, user_id
: Belongs to : user

MemberInfo
: Columns : DOB, age, age_updated_at, gender, id, user_id
: Belongs to : user
: Has many : educations , positions

MonthlyMetric
: Columns : avatar_percentage, avatar_percentage_new_users, average_profile_completeness, date, donation_optin_percentage, id, median_donation_percentage, number_users_tracking_donations, total_donations

Page
: Columns : body, created_at, header_title, id, just_a_link, menu_display, menu_display_in_footer, menu_priority, menu_sidebar, menu_top_level, parent_id, show_box, slug, title, updated_at
: Has many : page_feedbacks

PageFeedback
: Columns : comments, created_at, id, page_id, rating, updated_at, user_id, video_id
: Belongs to : page , user

Position
: Columns : current_position, end_date_month, end_date_year, etkh_profile_id, id, member_info_id, organisation, position, start_date_month, start_date_year
: Belongs to : etkh_profile , member_info

ProfileOptionActivity
: Columns : id, title
: Has many : etkh_profiles_profile_option_activities

ProfileOptionCause
: Columns : id, title
: Has many : etkh_profiles_profile_option_causes

Role
: Columns : created_at, id, name, updated_at
: Has many : roles_users

RolesUser
: Join Table.
: Columns : role_id, user_id
: Belongs to : role , user

Supporter
: Columns : anonymous, created_at, dont_email_me, email, id, name, updated_at

Survey
: Columns : created_at, email_box, id, id_box, name_box, slug, title, updated_at, url

Team Role
: Model, no controller or schema.

Tagging
: This comes from a gem.
: Columns : context, created_at, id, tag_id, taggable_id, taggable_type, tagger_id, tagger_type
: Belongs to : tag

Tag
: This comes from a gem.
: Columns : id, name
: Has many : taggings

User
: Columns : authentication_token, avatar_content_type, avatar_file_name, avatar_file_size, avatar_remote_url, avatar_updated_at, confirmation_sent_at, confirmation_token, confirmed_at, created_at, current_sign_in_at, current_sign_in_ip, email, encrypted_password, external_facebook, external_linkedin, external_twitter, external_website, id, last_sign_in_at, last_sign_in_ip, linkedin_email, location, name, notifications_on_comments, notifications_on_forum_posts, omniauth_signup, phone, real_name, remember_created_at, reset_password_sent_at, reset_password_token, sign_in_count, slug, updated_at
: Has many : authentications , blog_posts , comments , discussion_posts , donations , etkh_profiles , linkedin_infos , member_infos , page_feedbacks , roles_users , votes

UserSelection
: Model, no controller or schema.

Version
: Columns : created_at, event, id, item_id, item_type, object, whodunnit

Video
: Model, no controller or schema.

Vote
: Columns : created_at, id, positive, post_id, post_type, updated_at, user_id
: Belongs to : user

WeeklyMetric
: Columns : avatar_percentage, avatar_percentage_new_users,
average_profile_completeness, date, donation_optin_percentage, id,
median_donation_percentage
