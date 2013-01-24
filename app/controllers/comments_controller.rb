class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    @comment = Comment.new( params[:comment] )
    @comment.user = current_user if current_user

    if @comment.save
      if @comment.blog_post
        BlogPostMailer.new_comment(@comment).deliver!
        post = @comment.blog_post
      else
        DiscussionPostMailer.new_comment(@comment).deliver!
        post = @comment.discussion_post
      end

      ##email anyone who already made a comment

      #create an array of users who have also made comments on this post
      #to ensure they are not mailed multiple times
      users = []
      post.comments.each do |c|
        #check user is not current user
        if c.user != current_user
          # #check user has not already been emailed
          if !users.include?(c.user)
            #mail user
            CommentMailer.new_comment(c.user, @comment).deliver!
            #add to list of users already mailed
            users << c.user
          end
        end
      end

      render 'comments/create'
    else
      render 'comments/error'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end
end
