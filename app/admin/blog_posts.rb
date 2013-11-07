ActiveAdmin.register BlogPost do
  menu :if => proc{ can?(:read, BlogPost) }

  controller.authorize_resource

  scope :draft
  scope :published

  index do
    column :created_at
    column :title
    column :author
    column :user
    Rating::CATEGORIES.each do |rating|
      column rating do |p| 
        p.average_rating(rating)
      end
    end
    column :total_average_rating, :sortable => false
    column :draft do |p|
      p.draft? ? "<span class='status warn'>draft</span>".html_safe : ""
    end
    default_actions
  end

  show do |post|
    attributes_table do
      row :title
      row :author
      row :user
      row :attribution
      row :created_at
      row :draft do
        post.draft? ? "<span class='status warn'>draft</span>".html_safe : "false"
      end
      row :body do
        markdown post.body
      end
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :body
      f.input :teaser
      f.input :author
      f.input :user, :collection => User.order("name ASC")
      f.input :attribution
      f.input :created_at
      f.input :draft
      f.input :tag_list
      f.input :type_list,  :multiple => true, :collection => BlogPost.get_types, :as => :check_boxes
      f.input :category_list,  :multiple => true, :collection => BlogPost.get_types, :as => :check_boxes
    end
    f.buttons
  end

  csv do 
    column :title
    column :url
    column :author
    column :user do |p|
      p.user.name if !p.user.nil?
    end
    column :attribution
    column :created_at
    column :word_count do |p|
      p.body.split.size
    end
    column :tag_list
    column :category_list
    column :type_list
    column :ratings do |p|
      p.ratings.count
    end
    column :total_average_rating
    Rating::CATEGORIES.each do |rating|
      column rating do |p| 
        p.average_rating(rating)
      end
    end
    column :facebook_likes
    column :category

  end

  # for History sidebar in show view
  controller do
    def show
      @post = BlogPost.find(params[:id])
      @versions = @post.versions 
      @post = @post.versions[params[:version].to_i].reify if params[:version]
      show! #it seems to need this
    end
  end
  sidebar :versions, :partial => "admin/version_sidebar", :only => :show

  sidebar :view_on_site, :only => :show do
    @post = BlogPost.find(params[:id])
    link_to "View live on site", blog_post_path(@post)
  end
end
