class CommentMailer < ActionMailer::Base
	default :from => 'admin@80000hours.org',
					:return_path => 'admin@80000hours.org'

	def new_comment(user, comment)
    if user && user.email
        @commenter_name = (comment.user ? comment.user.first_name : comment.name)

        #get title and url of post the comment is on
        if comment.blog_post
        	@comment_post_title = comment.blog_post.title
        	@comment_post_url = blog_post_url(comment.blog_post)
        else
        	@comment_post_title = comment.discussion_post.title
        	@comment_post_url = discussion_post_url(comment.discussion_post)
        end

        mail(:to => user.email,
             :subject => "[80,000 Hours] New comment on #{@comment_post_title}"
        )
    end
  end
end