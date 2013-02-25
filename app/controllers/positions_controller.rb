class PositionsController < ApplicationController
  def new
    @position = Position.new
    render 'etkh_profiles/positions/new'
  end

  def create
    @new_position = Position.new(params[:position])
    @new_position.etkh_profile_id = params[:position][:etkh_profile_id]
    @new_position.save
    render 'etkh_profiles/positions/create'
  end

  def edit

  end

  def update

  end

  def destroy

  end
end