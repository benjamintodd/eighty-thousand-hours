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
    column 'writing time (hours)', :sortable => true do |p|
      p.writing_time
    end
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
      row :writing_time
      row :type_list
      row :tag_list
      row :category_list
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
      f.input :body, :input_html => { :rows => 40 }
      f.input :teaser, :input_html => { :rows => 20 }
      f.input :author
      f.input :user, :collection => User.order("name ASC")
      f.input :attribution
      f.input :created_at
      f.input :draft
      f.input :writing_time, :label => "Writing Time (hours)"
      f.input :tag_list
      f.input :image_attribution, :input_html => { :rows => 4 }
      f.input :type_list,  :multiple => true, :collection => BlogPost::TYPES, :as => :check_boxes
      f.input :category_list, :multiple => true, :collection => (t 'tags.all_careers'), :as => :check_boxes
    end
    f.actions
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
    column :writing_time

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
