Rails.application.routes.draw do
  resources :images, only: :index
  mount Fogged::Engine => "/"
end
