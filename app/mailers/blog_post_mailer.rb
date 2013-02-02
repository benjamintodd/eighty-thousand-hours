class BlogPostMailer < ActionMailer::Base
  default :from => 'admin@80000hours.org',
          :return_path => 'admin@80000hours.org'

  def new_comment(comment)
    @comment = comment
    @commenter_name = (@comment.user ? comment.user.first_name : comment.name)

    post = comment.get_post
    @comment_post_title = post.title
    @comment_post_url = blog_post_url(comment.commentable)

    mail(:to => post.user.email,
         :subject => "[80,000 Hours - Blog] New comment on #{@comment_post_title}"
    )
  end
end
