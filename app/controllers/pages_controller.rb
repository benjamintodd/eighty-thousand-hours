class PagesController < ApplicationController
  before_filter :get_user, :only => [:index,:new,:edit]
  before_filter :accessible_roles, :only => [:new, :edit, :show, :update, :create]
  load_and_authorize_resource :only => [:show,:new,:destroy,:edit,:update]
  layout "application", :except => [:home, :coaching_overview]
  layout "open", :only => [:home, :coaching_overview]
 
  def index
    @pages = Page.all
  end

  def show
    @page = Page.find(params[:id])

    # if we have set a custon header_title then we should use that
    # otherwise use the page title (which maps to the URL slug)
    @title = ((@page.header_title.to_s == '') ? @page.title : @page.header_title)
    
    @menu_current = @page.title
    @menu_root = @page.root.title

    # otherwise render show.html...
  end

  def home
    layout = "open"
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
   
    @page.attributes = params[:page]
    if params[:preview_button] or !@page.save
      render :action => 'edit'
    else
      flash[:"alert-success"] = "Page was successfully updated"
      redirect_to(@page)
    end

    expire_fragment(controller: "pages", action: "show")
  end

  def new
    @page = Page.new
  end
  
  def create
    @page = Page.new(params[:page])
     
    if @page.save
      flash[:"alert-success"] = 'Page was successfully created'
      redirect_to(@page)
    else
      render :action => "new"
    end

    expire_fragment(controller: "pages", action: "show")
  end

  def destroy
    if can? :manage, Page
      @page = Page.find(params[:id])
      begin
        @page.destroy
        flash[:"alert-success"] = 'Page successfully destroyed'
      rescue
        flash[:"alert-error"] = 'Failed to destroy page'
      end
      redirect_to :action => 'index'
    end
  end

  def accessible_roles
    @accessible_roles = Role.accessible_by(current_ability,:read)
  end
  def get_user
    @current_user = current_user
  end

  def survey_test
    if !current_user
      redirect_to :root
    end
  end

  def video
    @video_no = params[:id].to_i
    @video_id = [nil, "JQcfoboTomg","u2XNfeIASoA","pTYiwLcBFH4"][@video_no]
    @video_title = [nil, 
                    "We Want You to Change the World",
                    "Which Careers Make The Most Difference?",
                    "Which Career Should You Take?"][@video_no]
  end

  def endorsements
    @title = 'Endorsements for 80,000 Hours'
    @endorsements = t 'endorsements'
    @menu_current = 'Endorsements'
    @menu_root = 'About Us'
  end

  def meet_the_team
    @title = "Our Team"
  end

  def coaching_overview
    @title = "Social Impact Coaching"
    @subheader = "Coaching"
  end

  def coaching_information
    @title = "Social Impact Coaching"
    @subheader = "Coaching"
  end

  def coaching_application
    @title = "Social Impact Coaching"
    @subheader = "Coaching"
  end

  def coaching_application_form
    @title = "Social Impact Coaching"
    @subheader = "Coaching"
  end

  def coaching_confirmation
    redirect_to '/coaching/overview', :flash => { :error => "WHATSUP"}
    flash[:"alert-success"] = "Thanks! We've received your information and we'll be in touch soon!"
    @title = "Social Impact Coaching"
    @subheader = "Coaching Confirmation"
  end
end
