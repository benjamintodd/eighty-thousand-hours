class PageFeedbacksController < ApplicationController
  def new
    @page_feedback = PageFeedback.new params[:page_feedback]

    @page_id = params[:page_feedback][:page_id] 
    unless @page_id.blank?
      @page = Page.find params[:page_feedback][:page_id] 
      @page_feedback.page = @page
    end

    session[:return_to] ||= request.referer
  end

  def create
    @page_feedback = PageFeedback.new params[:page_feedback]

    @page_id = params[:page_feedback][:page_id] 
    unless @page_id.blank?
      @page = Page.find params[:page_feedback][:page_id] 
      @page_feedback.page = @page
    end

    if @page_feedback.save
      redirect_to (session[:return_to] || :root), notice: 'Feedback submitted.'
    else
      render action: "new" 
    end
  end
end
