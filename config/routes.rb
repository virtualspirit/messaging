Messaging::Engine.routes.draw do
  namespace :api do
    resources :conversations do
      member do
        resources :messages do
          member :reactions
        end
        resources :members
        resource :reads
      end
    end
  end
end