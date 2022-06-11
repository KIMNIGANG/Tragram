Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # get 'home/index':
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'log_out', to: 'sessions#destroy', as: 'log_out'

  # logged_in? -> make new project(in the static_page_controller). 
  # just show them. not make
  # get ':user_id/add_project', to: 'users#add_project'
  get ':project_id', to: 'projects#show'

  # is it ok to use the primary key to the url?
  # same as new project. just show
#  get ':project_id/post_id', to: 'project_id/post_id'

  resources :sessions, only: %i[create destroy]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html'
  #
end
