module BlogPostsHelper
  include ActsAsTaggableOn::TagsHelper

  def link_to_blog_post_author(post)
    if post.user && post.user.etkh_profile
      (link_to post.user.name, "/members/#{post.user.slug}")
    else
      post.author
    end
  end

  def link_to_blog_post_contents(post,length=35)
    link_to(truncate(post.title, length: length), blog_post_path( post ))
  end

  def get_popular_posts
    posts = []
  	if session[:popular_posts] && (Time.now - session[:popular_posts_updated_at].to_datetime) < 30.minutes
      session[:popular_posts].each do |post_id|
  		  posts << BlogPost.find_by_id(post_id)
      end
    else
      posts = BlogPost.by_popularity(5)
      session[:popular_posts] = []
      posts.each do |post|
        session[:popular_posts] << post.id
      end
      session[:popular_posts_updated_at] = Time.now.to_s
    end
    return posts
  end
end
