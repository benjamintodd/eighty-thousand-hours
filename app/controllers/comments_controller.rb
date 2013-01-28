class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    @comment = Comment.new( params[:comment] )
    @comment.user = current_user if current_user

    if @comment.save
      if @comment.blog_post
        post = @comment.blog_post
        BlogPostMailer.new_comment(@comment).deliver!
      else
        post = @comment.discussion_post
        if post.user.notifications_on_forum_posts
          DiscussionPostMailer.new_comment(@comment).deliver!
        end
      end

      ##email anyone who already made a comment

      #create an array of users who have also made comments on this post
      #to ensure they are not mailed multiple times
      users = []

      #user who made post has already been emailed
      users << post.user

      post.comments.each do |c|
        #check user is not current user
        if c.user != current_user
          #check user has not already been emailed
          if !users.include?(c.user)             
            #mail user
            if c.user.notifications_on_comments
              CommentMailer.new_comment(c.user, @comment).deliver!
            end

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
