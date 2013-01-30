class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    parent = get_parent

    @comment = parent.comments.build(params[:comment])
    @comment.user = current_user if current_user
    
    if @comment.save
      post = @comment.get_top_parent_comment.commentable

      # if @comment.commentable_type == "BlogPost"
      #   BlogPostMailer.new_comment(@comment).deliver!
      # elsif @comment.commentable_type == "DiscussionPost"
      #   if post.user.notifications_on_forum_posts
      #     DiscussionPostMailer.new_comment(@comment).deliver!
      #   end
      # end

      #email anyone who already made a comment
      #mail_previous_commenters(post)

      #create array of comment ids in hierarchy
      #this is then used in create.js.erb 
      @comment_hierarchy_ids = []
      if @comment.commentable_type == "Comment"
        parent_temp = parent
        @comment_hierarchy_ids << parent_temp.id

        while parent_temp.commentable_type != "BlogPost" && parent_temp.commentable_type != "DiscussionPost"
          parent_temp = Comment.find_by_id(parent_temp.commentable_id)
          @comment_hierarchy_ids << parent_temp.id
        end
      end

      render 'comments/create'
    else
      render 'comments/error'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])

    #get child comments
    child_comments = Comment.where(:commentable_id => @comment.id)

    #loop through child comments and destroy them
    child_comments.each do |c|
      c.destroy   #this performs recursion on next generation
    end

    @comment.destroy
  end


  protected

  def mail_previous_commenters(post)
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
  end

  def get_parent
    if params[:comment][:commentable_type] == "BlogPost"
      return BlogPost.find_by_id(params[:comment][:commentable_id])
    elsif params[:comment][:commentable_type] == "DiscussionPost"
      return DiscussionPost.find_by_id(params[:comment][:commentable_id])
    elsif params[:comment][:commentable_type] == "Comment"
      return Comment.find_by_id(params[:comment][:commentable_id])
    end
  end
end
