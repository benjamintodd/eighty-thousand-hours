require 'spec_helper'

describe "article_ratings/show" do
  before(:each) do
    @article_rating = assign(:article_rating, stub_model(ArticleRating,
      :overall => "",
      :user => "",
      :blogpost => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
  end
end
