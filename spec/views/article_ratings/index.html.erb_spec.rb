require 'spec_helper'

describe "article_ratings/index" do
  before(:each) do
    assign(:article_ratings, [
      stub_model(ArticleRating,
        :overall => "",
        :user => "",
        :blogpost => nil
      ),
      stub_model(ArticleRating,
        :overall => "",
        :user => "",
        :blogpost => nil
      )
    ])
  end

  it "renders a list of article_ratings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
