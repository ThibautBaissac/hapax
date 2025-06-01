Rails.application.routes.draw do
  mount RailsDesigner::Engine, at: "/rails_designer"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  resources :quotes
  resources :composers do
    resources :works, only: [ :new, :create, :show, :edit, :update, :destroy] do
      resources :movements, only: [ :new, :create, :show, :edit, :update, :destroy]
    end
  end
  devise_for :users
  resource :profile, only: [ :show, :edit, :update ], controller: "profile"
end
