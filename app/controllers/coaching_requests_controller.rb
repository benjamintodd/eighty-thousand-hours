class CoachingRequestsController < ApplicationController
  def new
    @coaching_request = CoachingRequest.new
  end

  def create
  end
end
