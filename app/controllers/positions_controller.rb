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
    @position = Position.find_by_id(params[:id])
    render 'etkh_profiles/positions/new'
  end

  def update
    debugger
    @position = Position.find_by_id(params[:id])
    @position.update_attributes(params[:position])
    render 'etkh_profiles/positions/update'
  end

  def destroy

  end
end