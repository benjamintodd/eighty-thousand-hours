class BlogPosts::RatingsController < ApplicationController

  def index
    @post = BlogPost.find(params[:blog_post_id])
    @ratings = @post.ratings
  end

  def show
    @post = BlogPost.find(params[:blog_post_id])
    @rating = Rating.find(params[:id])
  end

  def edit
    @post = BlogPost.find(params[:blog_post_id])
    @rating = Rating.find(params[:id])
  end

  def update
    @post = BlogPost.find(params[:blog_post_id])
    @rating = Rating.find(params[:id])
    if @rating.save
      flash[:"alert-success"] = 'Rating was successfully updated'
      redirect_to(blog_post_rating_path(@post, @rating))
    else
      render :action => "edit"
    end
  end

  def new
    @post = BlogPost.find(params[:blog_post_id])
    @rating = Rating.new
  end
  
  def create
    @post = BlogPost.find(params[:blog_post_id])
    @user = current_user
    @rating = Rating.new(params[:rating])
    @rating.blog_post = @post
    @rating.user = @user
     
    if @rating.save
      flash[:"alert-success"] = 'Rating was successfully created'
      redirect_to(blog_post_ratings_path(@post, @rating))
    else
      render :action => "new"
    end

  end

  def destroy
    @post = BlogPost.find(params[:blog_post_id])
    if can? :manage, rating
      @rating = rating.find(params[:id])
      begin
        @rating.destroy
        flash[:"alert-success"] = 'rating successfully destroyed'
      rescue
        flash[:"alert-error"] = 'Failed to destroy rating'
      end
      redirect_to :action => 'index'
    end
  end

end
