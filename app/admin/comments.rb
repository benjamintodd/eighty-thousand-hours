ActiveAdmin.register Comment, :as => "Blog/Discussion Comments" do
  index do
    column :id
    column :name
    column :email
    column :user
    column "Post Title", :commentable do |comment|
        comment.get_top_parent_comment.commentable.title
    end
    column :body
    column :created_at
    default_actions
  end
end
