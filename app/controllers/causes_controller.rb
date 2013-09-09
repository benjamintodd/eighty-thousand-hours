class CausesController < ApplicationController
  load_and_authorize_resource

  def index
    @causes = Cause.order("name ASC")
  end

  def show
    @cause = Cause.find(params[:id])
  end

  def new
    @cause = Cause.new( :user => current_user )
    authorize! :create, Cause, :message => "You need to <a href='/accounts/sign_in'>sign in</a> or <a href='/join'>sign up</a> to add a cause!".html_safe
  end

  def create
    @cause = Cause.new(params[:cause])

    if @cause.save
      flash[:"alert-success"] = "Successfully added #{@cause.name}."
    else
      render :new
    end
  end
end
