# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coaching_request do
    name "MyString"
    email "MyString"
    skype "MyString"
    current_situation "MyString"
    wants_better_world "MyString"
    dont_know_options "MyString"
    cant_decide "MyString"
    other_factors "MyString"
    current_career_plans "MyText"
    conterfactual_career_plans "MyText"
    current_donation_percent 1
    current_donation_target "MyString"
    counterfactual_donation_amount 1
    counterfactual_donation_target "MyString"
    questions "MyText"
  end
end
