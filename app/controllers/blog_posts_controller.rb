class BlogPostsController < ApplicationController
  load_and_authorize_resource :only => [:new,:create,:drafts,:edit,:update,:destroy]
  caches_action :index, cache_path: Proc.new { |controller| controller.params }, expires_in: 30.minutes, if: Proc.new { params[:page].nil? }
    layout "application", :except => [:show]
  layout "blog", :only => [:show]

  def index
    @posts = BlogPost.published.paginate(:page => params[:page], :per_page => 10)
    @condensed = false
    @heading = "80,000 Hours blog"

    @title = "Blog"
    @menu_root = "Blog"
    @subheader_search = true
  end

  def drafts
    @posts = BlogPost.by_author_drafts(current_user)
    @title = "Blog"
    @menu_root = "Blog"
  end

  def sorted
    @subheader_search = true
    @sort = params[:order]
    case @sort
    when 'popularity'
      @posts = BlogPost.by_popularity
      @condensed = true
      @heading = "Most popular posts"
     when 'date'
      @posts = BlogPost.published
      @condensed = true
      @heading = "All posts by date"
    else
      @posts = BlogPost.published.paginate(:page => params[:page], :per_page => 10)
      @condensed = false
      @heading = "80,000 Hours blog"
    end

    @title = "Blog"
    @menu_root = "Blog"
  end

  def show
    @post = BlogPost.find_by_id(params[:id])

    if current_user and can? :read, Rating
      @rating = Rating.new
      if current_user and @post.raters.include?(current_user)
        @user_rating = @post.ratings.where(user_id:current_user.id)[0]
      end
    end

    if @post.nil?
      flash[:"alert-error"] = "Sorry! You've followed a bad link, please <a href='contact-us'>contact support</a> and report the following:<br/> #{params[:controller]} => '#{params[:id]}'".html_safe
      redirect_to :action => 'index'
    else
      if @post.draft
        if cannot? :manage, BlogPost
          # user is not allowed to view drafts
          # so we redirect to the index
          flash[:"alert-error"] = "Sorry! You've followed a bad link, please <a href='contact-us'>contact support</a>!".html_safe
          redirect_to :action => 'index'
        end
      end

      @subheader_search = true
      @og_url = blog_post_url( @post )
      @og_desc = @post.get_teaser
      @og_type = "article"
      @tags = @post.tag_list

      @title = "Blog"
      @menu_root = "Blog"
    end
  end

  def author
    @heading = "BlogPosts by #{params[:id]}"
    @posts = BlogPost.by_author(params[:id],params[:page])
    @condensed = true
    @subheader_search = true

    render 'index'
  end

  def tag
    @heading = "BlogPosts tagged with '#{params[:id]}'"
    @posts = BlogPost.published.tagged_with(params[:id]).order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
    @condensed = true
    @subheader_search = true
    @title = "Blog: '#{params[:id]}' "

    render 'index'
  end

  # Atom feed
  def feed
    # this will be the name of the feed displayed on the feed reader
    @title = "80,000 Hours - Blog"

    # the blog posts
    @posts = BlogPost.published.limit(20)

    # this will be our feed's update timestamp
    @updated = @posts.first.updated_at unless @posts.empty?

    respond_to do |format|
      format.atom { render :layout => false } #views/posts/feed.atom.builder
    end
  end

  def edit
    @post = BlogPost.find( params[:id] )
    3.times { @post.attached_images.build }
  end

  def update
    @post = BlogPost.find( params[:id] )
    if @post.update_attributes( params[:blog_post] )
      redirect_to @post, :notice => "Post updated!"
    else
      render :edit
    end
    #expire_fragment(/.*blog.*/) # expires cached items which include 'blog' in the key
    expire_fragment("bpost-#{@post.id}")
  end

  def new
    @post = BlogPost.new
    3.times { @post.attached_images.build }
  end

  def create
    @post = current_user.blog_posts.new( params[:blog_post] )
    if @post.save
      redirect_to blog_post_path(@post), :notice => "Post created!"
    else
      render :new
    end
    #expire_fragment(/.*blog.*/) # expires cached items which include 'blog' in the key
  end

  def destroy
    @post = BlogPost.find( params[:id] )
    @post.destroy
    redirect_to blog_posts_path, :notice => "Post permanently deleted"
    #expire_fragment(/.*blog.*/) # expires cached items which include 'blog' in the key
    #expire_fragment("bpost-#{@post.id}")
  end

end
