module BlogPostsHelper
  include ActsAsTaggableOn::TagsHelper

  def link_to_blog_post_author(post)
    if post.user && post.user.etkh_profile
      (link_to post.user.name, "/members/#{post.user.slug}")
    else
      (link_to post.author, { :controller => 'blog_posts', :action => :author, :id => post.author })
    end
  end

  def link_to_blog_post_contents(post,length=35)
    link_to(truncate(post.title, length: length), blog_post_path( post ))
  end
end
