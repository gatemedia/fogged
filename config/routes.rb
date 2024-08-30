# frozen_string_literal: true
Fogged::Engine.routes.draw do
  resources :resources do
    put :confirm, on: :member
    post :zencoder_notification, on: :collection
  end
end
