class DiscussionPostMailer < ActionMailer::Base
  default :from => 'admin@80000hours.org',
          :return_path => 'admin@80000hours.org'

  def new_comment(comment)
    @email = comment.post_author_email

    if @email
      @comment = comment
      @commenter_name = (@comment.user ? comment.user.first_name : comment.name)

      post = comment.get_post
      @comment_post_title = post.title
      @comment_post_url = discussion_post_url(comment.commentable)

      @edit_account_path = '80000hours.org/accounts/edit'

      mail(:to => post.user.email,
           :subject => "[80,000 Hours - Discussion] New comment on #{@comment_post_title}"
      )
    end
  end
end
