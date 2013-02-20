class VotesController < ApplicationController
  def new
    user = current_user
    if params[:post_type] == "BlogPost"
      type = :blog
    elsif params[:post_type] == "DiscussionPost"
      type = :discussion
    elsif params[:post_type] == "Comment"
      type = :comment
    else
      return  #error
    end
    
    post = ''
    user_votes = ''
    if type == :blog
      post = BlogPost.find(params[:post])
      user_votes = Vote.by_post(post).by_user(user)
    elsif type == :discussion
      post = DiscussionPost.find(params[:post])
      user_votes = Vote.by_post(post).by_user(user)
    elsif type == :comment
      post = Comment.find(params[:post])
      user_votes = Vote.by_post(post).by_user(user)
    end

    up = (params[:up] == 'true')

    # check if user has already voted for this post
    if user_votes.empty?
      if type == :blog
        post.votes << Vote.new( :user => user, :post => post, :post_type => "BlogPost", :positive => up )
      elsif type == :discussion
        post.votes << Vote.new( :user => user, :post => post, :post_type => "DiscussionPost", :positive => up )
      elsif type == :comment
        post.votes << Vote.new( :user => user, :post => post, :post_type => "Comment", :positive => up )
      end
    else
      vote = user_votes.first
      if (up && vote.positive) || (!up && !vote.positive)
        # user already upvoted, and clicked up again
        # so we destroy the vote
        # and vice versa
        vote.destroy
      else
        # we had an upvote, and user clicked Down
        # so we change the upvote to a downvote
        # or vice versa
        vote.positive = !vote.positive
        vote.save
      end
    end

    @arrow_element = "#{up ? 'up-' : 'down-'}vote-#{post.id}"
    @arrow_element_other = "#{up ? 'down-' : 'up-'}vote-#{post.id}"
    @vote_element  = "total-votes-#{post.id}"
    @net_votes = post.net_votes

    respond_to do |format|
      format.js { render :layout => false }
    end
  end
end
