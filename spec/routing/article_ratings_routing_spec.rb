require "spec_helper"

describe ArticleRatingsController do
  describe "routing" do

    it "routes to #index" do
      get("/article_ratings").should route_to("article_ratings#index")
    end

    it "routes to #new" do
      get("/article_ratings/new").should route_to("article_ratings#new")
    end

    it "routes to #show" do
      get("/article_ratings/1").should route_to("article_ratings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/article_ratings/1/edit").should route_to("article_ratings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/article_ratings").should route_to("article_ratings#create")
    end

    it "routes to #update" do
      put("/article_ratings/1").should route_to("article_ratings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/article_ratings/1").should route_to("article_ratings#destroy", :id => "1")
    end

  end
end
