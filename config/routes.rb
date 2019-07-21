Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'pages#index'

  get 'women', to: 'products#women'
  get 'men', to: 'products#men'
  get 'kids', to: 'products#kids'
  get 'shop' => 'pages#shop'
  get 'about' => 'pages#about'
  post 'product_items/:id/add' => "product_items#add_quantity", as: "product_items_add"
  post 'product_items/:id/reduce' => "product_items#reduce_quantity", as: "product_items_reduce"

  resources :carts
  resources :product_items
  resources :orders
  resources :contacts
  resources :products
  resources :photos
  resources :quantity

end


