Rails.application.routes.draw do
  root 'home#index'
  resources :users
  get 'login', to: 'sessions#new', as: 'login' # login_path
  post 'login', to: 'sessions#create' # create action for login
  get 'logout', to: 'sessions#destroy', as: 'logout' # logout_path
end



