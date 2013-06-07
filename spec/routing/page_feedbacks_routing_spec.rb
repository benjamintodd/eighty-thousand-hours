require "spec_helper"

describe PageFeedbacksController do
  describe "routing" do

    it "routes to #index" do
      get("/page_feedbacks").should route_to("page_feedbacks#index")
    end

    it "routes to #new" do
      get("/page_feedbacks/new").should route_to("page_feedbacks#new")
    end

    it "routes to #show" do
      get("/page_feedbacks/1").should route_to("page_feedbacks#show", :id => "1")
    end

    it "routes to #edit" do
      get("/page_feedbacks/1/edit").should route_to("page_feedbacks#edit", :id => "1")
    end

    it "routes to #create" do
      post("/page_feedbacks").should route_to("page_feedbacks#create")
    end

    it "routes to #update" do
      put("/page_feedbacks/1").should route_to("page_feedbacks#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/page_feedbacks/1").should route_to("page_feedbacks#destroy", :id => "1")
    end

  end
end
