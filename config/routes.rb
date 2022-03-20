Rails.application.routes.draw do
  resources :developers do
    get 'search/:username', action: 'search', on: :collection
  end
end
