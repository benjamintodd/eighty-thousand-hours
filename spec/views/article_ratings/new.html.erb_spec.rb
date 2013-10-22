require 'spec_helper'

describe "article_ratings/new" do
  before(:each) do
    assign(:article_rating, stub_model(ArticleRating,
      :overall => "",
      :user => "",
      :blogpost => nil
    ).as_new_record)
  end

  it "renders new article_rating form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => article_ratings_path, :method => "post" do
      assert_select "input#article_rating_overall", :name => "article_rating[overall]"
      assert_select "input#article_rating_user", :name => "article_rating[user]"
      assert_select "input#article_rating_blogpost", :name => "article_rating[blogpost]"
    end
  end
end
