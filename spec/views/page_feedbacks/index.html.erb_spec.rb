require 'spec_helper'

describe "page_feedbacks/index" do
  before(:each) do
    assign(:page_feedbacks, [
      stub_model(PageFeedback,
        :rating => "Rating",
        :comments => "MyText",
        :page => nil
      ),
      stub_model(PageFeedback,
        :rating => "Rating",
        :comments => "MyText",
        :page => nil
      )
    ])
  end

  it "renders a list of page_feedbacks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Rating".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
