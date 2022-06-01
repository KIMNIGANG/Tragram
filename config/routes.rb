Rails.application.routes.draw do
  get 'home/index'
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'

  resources :sessions, only: %i[create destroy]
  get '/' => 'instagram_auth#index'
  get '/authpass', to: 'instagram_auth#auth_pass'
  #あるユーザーのmypage表示
  get '/:user_id/show', to:'users#show'

  #post追加
  get '/:project_id/add_post', to:'projects#add_post'

  #あるprojectのpost表示
  get '/:project_id', to: 'projects#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
