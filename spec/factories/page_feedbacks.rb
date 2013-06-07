# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page_feedback do
    rating "MyString"
    comments "MyText"
    page nil
  end
end
