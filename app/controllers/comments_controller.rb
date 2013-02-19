class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    # parent could be a blog post, discussion post or comment
    parent = get_parent

    @comment = parent.comments.build(params[:comment])
    @comment.user = current_user if current_user
    
    if @comment.save
      # get the blog or discussion post the comment has been posted on
      post = @comment.get_post

      # mail creator of post
      if post.instance_of?(BlogPost) && @comment.user != post.user
        BlogPostMailer.new_comment(@comment).deliver!
      elsif post.instance_of?(DiscussionPost) && @comment.user != post.user
        # check user notification settings
        if post.user.notifications_on_forum_posts
          DiscussionPostMailer.new_comment(@comment).deliver!
        end
      end

      #email anyone who already made a comment
      mail_previous_commenters(@comment, post)

      #create array of comment ids in hierarchy of nested comments
      #this is then used in create.js.erb 
      @comment_hierarchy_ids = []

      # if parent is a comment
      if @comment.commentable_type == "Comment"
        # add current parent id to array of ids
        parent_temp = parent
        @comment_hierarchy_ids << parent_temp.id

        # loop through parents and add their id to array
        # stop when the next parent is not a comment
        while parent_temp.commentable_type != "BlogPost" && parent_temp.commentable_type != "DiscussionPost"
          parent_temp = Comment.find_by_id(parent_temp.commentable_id)
          @comment_hierarchy_ids << parent_temp.id
        end
      end

      # call javascript to add new comment to page
      render 'comments/create'
    else
      render 'comments/error'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])

    #get child comments
    child_comments = Comment.where(:commentable_id => @comment.id)
    
    #if child comments exist mark comment as deleted but don't destroy
    if !child_comments[0].nil?
      @comment.update_column :body, "This comment has been deleted"
      @comment.update_column :user_id, nil
      @comment.update_column :name, nil
      @comment.update_column :email, nil
    else
      @comment.destroy
    end
    
    # call javascript to remove comment from page
    @comment_id = @comment.id
    render 'comments/destroy'
  end


  protected

  def mail_previous_commenters(comment, post)
    #create an array of users who have also made comments on this post
    #to ensure they are not mailed multiple times
    mailed_users = []

    # user who made post has already been emailed
    mailed_users << comment.get_post.user

    # mail all users who have commented on this post
    mail_recurse(post, mailed_users)
  end

  def mail_recurse(commentable, mailed_users)
    # work from top parent down hierarchy
    commentable.comments.each do |c|
      # check user is not current user
      if c.user != current_user
        # check user has not already been emailed
        if !mailed_users.include?(c.user)             
          # mail user if registered and their notification settings allow it
          if c.user && c.user.notifications_on_comments
            CommentMailer.new_comment(c.user, @comment).deliver!
          end

          # add to list of users already mailed
          mailed_users << c.user
        end
      end

      # recurse
      mail_recurse(c, mailed_users) if c
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
