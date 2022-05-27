Rails.application.routes.draw do
  get '/:user_id/mypage', to:'users#mypage'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
