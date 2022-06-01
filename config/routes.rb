Rails.application.routes.draw do
  #あるユーザーのmypage表示
  get '/:user_id/show', to:'users#show'

  #post追加
  get '/:project_id/add_post', to:'projects#add_post'

  #あるprojectのページを表示
  get '/project/:project_id', to: 'projects#show'

  resources :users, only:[:show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
