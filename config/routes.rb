Rails.application.routes.draw do

  get 'user/edit'
  get 'user/show'
  get 'profile/edit'
  patch 'profile/update'

  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :registrations => 'users/registrations'
   }
  root to: "application#index"

  resources :packages
  resources :partners

  resources :raffles

end
