Rails.application.routes.draw do
  #あるユーザーのmypage表示
  get '/:user_id/mypage', to:'users#mypage'

  #post追加
  get '/:project_id/add_post', to:'projects#add_post'

  #あるprojectのpost表示
  get '/:project_id', to: 'projects#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
