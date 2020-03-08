Rails.application.routes.draw do

  get 'throws/create'
  resources :games, only: [:show, :create] do
    resources :throws, only: [:create]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
