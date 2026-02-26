Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }, controllers: { sessions: "users/sessions" }

  resources :customers
  resources :drivers

  get "/me", to: "me#show"
  get "/health", to: "health#show"

  resources :loads do
    collection do
      get :active
    end
    resources :status_events, only: [ :create, :index ]
  end

  get "/dashboard", to: "dashboard#show"
end
