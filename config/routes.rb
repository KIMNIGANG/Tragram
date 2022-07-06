Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # get 'home/index':
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'


  # is it ok to use the primary key to the url?
  # same as new project. just show
#  get ':project_id/post_id', to: 'project_id/post_id'

  resources :sessions, only: %i[create destroy]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html'
  #
  get '/projects/:id', to: 'projects#show'
  post '/projects/:id', to: 'projects#update'
  resources :projects, only: %i[destroy create edit update show]
  resources :users, only: %i[show new destroy create]
  resources :posts, only: %i[show create destroy edit update new]


  #post 'projects/create',as:"projects"
  get '/instagram/auth' => 'instagram_auth#auth'
  get '/authpass' => 'instagram_auth#get_token'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get '/show_image' => 'instagram_auth#show_image'
  get'/posts/:id/insert_image/', to: 'instagram_auth#insert_image_to_post'
end
