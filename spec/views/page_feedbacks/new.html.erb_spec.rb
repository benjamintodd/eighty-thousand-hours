require 'spec_helper'

describe "page_feedbacks/new" do
  before(:each) do
    assign(:page_feedback, stub_model(PageFeedback,
      :rating => "MyString",
      :comments => "MyText",
      :page => nil
    ).as_new_record)
  end

  it "renders new page_feedback form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => page_feedbacks_path, :method => "post" do
      assert_select "input#page_feedback_rating", :name => "page_feedback[rating]"
      assert_select "textarea#page_feedback_comments", :name => "page_feedback[comments]"
      assert_select "input#page_feedback_page", :name => "page_feedback[page]"
    end
  end
end
