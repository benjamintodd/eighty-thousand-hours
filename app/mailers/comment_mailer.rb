class CommentMailer < ActionMailer::Base
	default :from => 'admin@80000hours.org',
					:return_path => 'admin@80000hours.org'

	def new_comment(user, comment)
    if user && user.email
        @commenter_name = (comment.user ? comment.user.first_name : comment.name)
        
        post = comment.get_post
        @comment_post_title = post.title

        #get title and url of post the comment is on
        if post.instance_of?(BlogPost)
        	@comment_post_url = blog_post_url(post)
        elsif post.instance_of?(DiscussionPost)
        	@comment_post_url = discussion_post_url(post)
        end

        @edit_account_path = '80000hours.org/accounts/edit'

        mail(:to => user.email,
             :subject => "[80,000 Hours] New comment on #{@comment_post_title}"
        )
    end
  end
end