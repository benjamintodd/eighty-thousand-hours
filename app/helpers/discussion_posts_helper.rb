module DiscussionPostsHelper
  def link_to_discussion_post_author( post )
    if post.user && post.user.etkh_profile
      link_to post.user.name, "/members/#{post.user.slug}"
    end
  end
end