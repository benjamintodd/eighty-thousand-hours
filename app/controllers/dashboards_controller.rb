class DashboardsController < ApplicationController

  def research
    @posts = BlogPost.order('created_at DESC')
  end

end
