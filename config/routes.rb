Messaging::Engine.routes.draw do
  namespace :api do
    resources :conversations
  end
end