EightyThousandHours::Application.routes.draw do
  get "coaching_requests/new"

  get "coaching_requests/create"

  get "coaching_requests_controller/new"

  get "coaching_requests_controller/create"

  resources :authentications do
    collection do
      get 'create_new_account'
      get 'linkedin_signup'
      get 'linkedin_signup_callback'
      get 'linkedin_callback'
      get 'linkedin_signin'
      get 'linkedin_signin_callback'
      get 'linkedin_getprofile'
      get 'linkedin_getprofile_callback'
      get 'linkedin_invite_connection'
      get 'linkedin_invite_connection_callback'
      get 'linkedin_getprofile_and_link_account'
      get 'linkedin_getprofile_and_link_account_callback'
    end
  end

  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  ActiveAdmin.routes(self)

  devise_for :users, :path => 'accounts',
                     :controllers => { :sessions => 'sessions',
                                       :registrations => 'registrations' }

  match '/accounts/merge' => 'users#merge'

  match '/blog/feed.atom' => 'blog_posts#feed', :as => :feed, :defaults => { :format => 'atom' }
  resources :blog_posts, :path => 'blog' do
    resources :comments
    collection do
      get 'drafts'
      get :tag
      get :author
      get :vote
      get :sorted
    end
  end

  match 'forum'  => 'discussion_posts#index'
  resources :discussion_posts, :path => 'discussion' do
    resources :comments
    collection do
      get 'drafts'
    end
  end

  resources :comments do
    resources :comments
  end

  resources :causes, :only => [:new,:create,:show,:index], :path => 'donations/causes'
  resources :donations, :only => [:new,:create,:update,:show,:index,:edit]

  resources :votes, :only => [:new,:create,:delete]

  resources :supporters, :only => [:new, :create], :path => 'show-your-support'
  match 'show-your-support' => 'supporters#new'

  resources :chat_requests, :only => [:new,:create], :path => 'chat-to-us'
  match 'chat-to-us' => 'chat_requests#new'

  resources :career_advice_requests, :only => [:new,:create], :path => 'request-a-career-advice-session'
  match 'request-a-career-advice-session' => 'career_advice_requests#new'

  #temporary page for particular event
  resources :event_booking_requests, only: [:new,:create]

  resources :endorsements, :only =>[:index]
  resources :videos, :only =>[:index]

  match '/members/all'  => 'etkh_profiles#index'
  match '/members'      => 'etkh_profiles#our_members'
  match '/members/get_more_members' =>'etkh_profiles#get_more_members'
  resources :etkh_profiles, :path => "members", :only => [:new,:create,:show,:index] do
    resources :positions, :only => [:new,:create,:edit,:update,:destroy]
    resources :educations, :only => [:new,:create,:edit,:update,:destroy]
    collection do
      get 'show_linkedin_popup'
      get 'display_profile_hover_info'
      post 'search'
    end
  end

  match 'users' => 'users#index'
  resources :users, :path => 'accounts', :only => [:show,:edit,:update,:destroy] do
    resources :etkh_profiles 
    collection do
      get 'all'
      get 'email_list'
      put 'contact_user'
      get 'user_activity'
      get 'remove_avatar'
      get 'initialise_invite_linkedin_connection'
    end
  end
  match '/users/initalise_contact_user' => 'users#initalise_contact_user'

  resources :surveys do
    collection do
      get 'new_member_survey'
      put 'completed_new_member_survey'
    end
  end

  # metrics output
  match "metrics/weekly_metrics.csv"  => 'metrics#weekly_metrics'
  match "metrics/monthly_metrics.csv" => 'metrics#monthly_metrics'

  # pages which don't live in the database as they can't be
  # converted to pure Markdown
  match 'events'             => 'info#events'
  match 'events/past-events' => 'info#past_events'
 
  # pages from old HIC site
  match 'ethical-career'                => 'info#banker_vs_aid_worker'
  match 'old-ethical-career'            => 'info#ethical_career'
  match 'what-you-can-do'               => 'info#what_you_can_do'
  match 'what-you-can-do/my-donations'  => 'info#my_donations'
  match 'what-we-do'                    => 'info#what_we_do'

  # pages kept in views/pages

  match 'dashboard'          => 'pages#dashboard'
  match 'search'        => 'pages#search'
  match 'sitemap'       => 'pages#sitemap'
  match 'survey_test'   => 'pages#survey_test'

  # redirects
  match 'high-impact-careers', to: redirect('/types-of-career')
  match 'how-we-are-different', to: redirect('/our-features')
  
  resources :pages
  root :to => 'pages#home'
end
