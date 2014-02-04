Bestnights::Application.routes.draw do
  # devise_for :users
  devise_for :users, :controllers => {:sessions => 'sessions'}
      
  root :to => "home#index"
  
  namespace :admin do
    # authenticated :user do
      get '/' => 'dashboard#index'    
    # end
    
  end
  
  namespace :manager do
    # authenticated :user do
      get '/' => 'dashboard#index'    
    # end
  end
  
  match 'new_manager' => 'users#new_manager', :via => :get, :as => 'new_manager'
  match 'new_manager' => 'users#create_manager', :via => :post, :as => 'new_manager'
  
  resources :users 
  resources :hotels
  resources :room_types
  resources :bed_types
  resources :room_attributes
  resources :hotel_attributes
  resources :messages
  resources :travelers
end
