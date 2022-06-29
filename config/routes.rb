Rails.application.routes.draw do
  get 'home/index'
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'

  resources :sessions, only: %i[create destroy]
  get '/instagram_index' => 'instagram_auth#index'
  get '/authpass' => 'instagram_auth#get_token'
  get '/get_media_test' => 'instagram_auth#get_media_test'
  get '/projects/:id/show_image' => 'instagram_auth#show_image'

end
