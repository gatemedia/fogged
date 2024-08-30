# frozen_string_literal: true
Rails.application.routes.draw do
  resources :images, only: :index
  mount Fogged::Engine => "/"
end
