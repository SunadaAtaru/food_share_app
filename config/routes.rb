Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  root 'home#index'
  get 'home/index', to: 'home#index' # ここを追加
  # ユーザー登録（サインアップ）用のルートを追加
  get 'signup', to: 'users#new', as: 'signup'
  resources :users
  get 'login', to: 'sessions#new', as: 'login' # login_path
  post 'login', to: 'sessions#create' # create action for login
  delete 'logout', to: 'sessions#destroy', as: 'logout' # logout_path
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
end



