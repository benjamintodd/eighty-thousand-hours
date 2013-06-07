require 'spec_helper'

describe "page_feedbacks/show" do
  before(:each) do
    @page_feedback = assign(:page_feedback, stub_model(PageFeedback,
      :rating => "Rating",
      :comments => "MyText",
      :page => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Rating/)
    rendered.should match(/MyText/)
    rendered.should match(//)
  end
end
