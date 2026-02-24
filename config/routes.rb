Rails.application.routes.draw do
  resources :customers, only: %i[index show create update destroy]
  resources :drivers,   only: %i[index show create update destroy]
  resources :loads do
    resources :status_events, only: %i[create index]
  end

  get "/dashboard", to: "dashboard#show"
end
