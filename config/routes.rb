Fogged::Engine.routes.draw do
  resources :resources
  put "resources/:id/confirm" => "resources#confirm"
end
