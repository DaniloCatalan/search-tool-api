Rails.application.routes.draw do
  resources :developers, only: [:index, :create] do
    get 'show_user/:username', action: 'show_user', on: :collection
    get 'search/:language', action: 'search', on: :collection
  end
end
