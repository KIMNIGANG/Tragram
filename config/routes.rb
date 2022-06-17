Rails.application.routes.draw do
  get 'home/index'
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'

  resources :sessions, only: %i[create destroy]
  get '/instagram_index' => 'instagram_auth#index'
  get '/authpass' => 'instagram_auth#get_token'
  resources :posts, only: %i[show create edit destroy update]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
