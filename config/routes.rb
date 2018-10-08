Rails.application.routes.draw do
  root 'static_pages#home'
  get 'about' => "static_pages#about"
  get 'help' => "static_pages#help"
  get 'contact' => "static_pages#contact"
  get 'signup' => "users#new"
  post 'signup' => "users#create"

  get 'login' => "sessions#new"
  post 'login' => "sessions#create"
  delete 'logout' => "sessions#destroy"
  resources :users do
    member do
      get :following, :followers # users/1/following or followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :microposts, only: [:create, :destroy] # new, edit アクションは不要
  resources :relationships, only: [:create, :destroy] # 同上
end
