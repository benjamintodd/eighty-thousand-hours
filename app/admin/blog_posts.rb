ActiveAdmin.register BlogPost do
  menu :if => proc{ can?(:read, BlogPost) }

  controller.authorize_resource

  scope :draft
  scope :published

  index do
    column :created_at
    column :title
    column :user
    column :author
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
      row :draft do
        post.draft? ? "<span class='status warn'>draft</span>".html_safe : "false"
      end
      row :body do
        markdown post.body
      end
      row :type_list
      row :top_career_list
      row :all_career_list
      row :top_cause_list
      row :all_cause_list
      row :topic_list
      row 'Other Tags' do 
        post.tag_list
      end
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :body, :input_html => { :rows => 50 }
      f.input :teaser, :input_html => { :rows => 20 }
      f.input :user, :collection => User.order("name ASC"), :label => 'Author'
      f.input :author, :label => "Author (if user isn't in database)"
      f.input :attribution, :label => "Attibution (a blurb about the author, specifically for external authors)"
      f.input :published_at
      f.input :draft
      f.input :writing_time, :label => "Writing Time (hours)"
      f.input :image_attribution, :input_html => { :rows => 4 }
      f.input :type_list,  :multiple => true, :collection => (t 'tags.types'), :as => :check_boxes
      f.input :top_career_list, :multiple => true, :collection => (t 'tags.top_careers'), :as => :check_boxes
      f.input :all_career_list, :multiple => true, :collection => (t 'tags.all_careers'), :as => :check_boxes
      f.input :top_cause_list, :multiple => true, :collection => (t 'tags.top_causes'), :as => :check_boxes
      f.input :all_cause_list, :multiple => true, :collection => (t 'tags.all_causes'), :as => :check_boxes
      f.input :topic_list, :multiple => true, :collection => (t 'tags.topics'), :as => :check_boxes
      f.input :tag_list, :label => 'Other Tags'
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
    column :updated_at
    column :published_at
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
