# -*- coding: utf-8 -*-
class CoachingRequest < ActiveRecord::Base
  attr_accessible :cant_decide, :conterfactual_career_plans, :counterfactual_donation_amount, :counterfactual_donation_target, :current_career_plans, :current_donation_percent, :current_donation_target, :current_situation, :dont_know_options, :email, :name, :other_factors, :questions, :skype, :wants_better_world, :other_causes

  SituationOptions = {a: "I’ve got a plan for my career and I’d like help on how to accomplish it.",
    b: "I’m trying to choose between two or more options.",
    c: "I have no idea what to do."}

  BetterWorldOptions = {
    a: "An admirable goal, but not something I’m really considering for my own career.",
    b: "One of many considerations for choosing a career.",
    c: "One of the most important factors in choosing my career.",
    d: "The most important factor in choosing my career.",
    e: "The only relevant factor in choosing my career."
  }

  LimitingFactors = {
    a: "doesn’t prevent me at all",
    b: "slightly prevents me",
    c: "prevents me quite a lot",
    d: "very much prevents me"
  }

  CauseOptions = {
    a: "Global poverty", 
    b: "Improving the far future",
    c: "Ending factory farming",
    d: "Global prioritisation",
    e: "Promoting effective altruism",
    f: "Improving decision making",
    g: "Meta-research (improving academic research practices)"
  }

  SwitchingCauseOptions = {
    a: "Very likely",
    b: "Likely",
    c: "Not likely",
    d: "Highly unlikely"
  }
end
