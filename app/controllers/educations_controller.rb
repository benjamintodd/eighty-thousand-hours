class EducationsController < ApplicationController
  def new
    @education = Education.new
    render 'etkh_profiles/educations/show_form'
  end

  def create
    @new_education = Education.new(params[:education])
    @new_education.etkh_profile_id = params[:education][:etkh_profile_id]
    @new_education.save
    render 'etkh_profiles/educations/redraw'
  end

  def edit
    @education = Education.find_by_id(params[:id])
    render 'etkh_profiles/educations/edit'
  end

  def update
    if params[:cancel] != "true"
      @education = Education.find_by_id(params[:id])
      @education.update_attributes(params[:education])
    end
    render 'etkh_profiles/educations/redraw'
  end

  def destroy
    @education = Education.find_by_id(params[:id])
    @education.destroy
    render 'etkh_profiles/educations/redraw'
  end
end