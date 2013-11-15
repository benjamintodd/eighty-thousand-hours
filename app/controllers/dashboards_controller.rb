class DashboardsController < ApplicationController

  def research
    @posts = BlogPost.published.order('created_at DESC')
  end

end
