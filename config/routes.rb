Rails.application.routes.draw do
  get '/' => 'instagram_auth#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
