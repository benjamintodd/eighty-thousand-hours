require 'spec_helper'

describe "article_ratings/edit" do
  before(:each) do
    @article_rating = assign(:article_rating, stub_model(ArticleRating,
      :overall => "",
      :user => "",
      :blogpost => nil
    ))
  end

  it "renders the edit article_rating form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => article_ratings_path(@article_rating), :method => "post" do
      assert_select "input#article_rating_overall", :name => "article_rating[overall]"
      assert_select "input#article_rating_user", :name => "article_rating[user]"
      assert_select "input#article_rating_blogpost", :name => "article_rating[blogpost]"
    end
  end
end
