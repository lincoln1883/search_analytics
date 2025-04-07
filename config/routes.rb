Rails.application.routes.draw do
  root "searches#index"
  resources :searches, only: [:index, :create]
  get 'analytics', to: 'analytics#index'
  
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
