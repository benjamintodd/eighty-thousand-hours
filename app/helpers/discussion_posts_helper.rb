module DiscussionPostsHelper
  def link_to_discussion_post_author( post )
    if post.user && post.user.etkh_profile
      link_to post.user.name, "/members/#{post.user.slug}"
    else
      link_to post.name, (discussion_post_path( post ))
    end
  end
end