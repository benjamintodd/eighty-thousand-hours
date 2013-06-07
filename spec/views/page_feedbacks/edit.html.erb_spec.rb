require 'spec_helper'

describe "page_feedbacks/edit" do
  before(:each) do
    @page_feedback = assign(:page_feedback, stub_model(PageFeedback,
      :rating => "MyString",
      :comments => "MyText",
      :page => nil
    ))
  end

  it "renders the edit page_feedback form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => page_feedbacks_path(@page_feedback), :method => "post" do
      assert_select "input#page_feedback_rating", :name => "page_feedback[rating]"
      assert_select "textarea#page_feedback_comments", :name => "page_feedback[comments]"
      assert_select "input#page_feedback_page", :name => "page_feedback[page]"
    end
  end
end
