class PositionsController < ApplicationController
  def new
    @position = Position.new
    render 'etkh_profiles/positions/show_form'
  end

  def create
    @new_position = Position.new(params[:position])
    @new_position.etkh_profile_id = params[:position][:etkh_profile_id]
    @new_position.save
    render 'etkh_profiles/positions/redraw_positions'
  end

  def edit
    @position = Position.find_by_id(params[:id])
    #render 'etkh_profiles/positions/show_form'
    render 'etkh_profiles/positions/edit'
  end

  def update
    if params[:cancel] != "true"
      @position = Position.find_by_id(params[:id])
      @position.update_attributes(params[:position])
    end
    render 'etkh_profiles/positions/redraw_positions'
  end

  def destroy
    @position = Position.find_by_id(params[:id])
    
    # remove position from this profile
    @position.etkh_profile_id = nil
    @position.save

    # will destroy position if it does not also belong to member_info
    @position.destroy
    
    render 'etkh_profiles/positions/redraw_positions'
  end
end