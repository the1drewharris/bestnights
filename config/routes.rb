Bestnights::Application.routes.draw do
  
  resources :commission_rates

  resources :rate_categories

  resources :rates do
    post 'add_room_rate_details'
    post 'update_room_rates'
  end

  resources :pages

  resources :contacts

  match '/payments/payment', :to => 'payments#payment', :as => 'paymentspayment', :via => [:get]

  match '/payments/thank_you', :to => 'payments#thank_you', :as => 'payments_thank_you', :via => [:get]

  devise_for :users#, :controllers => {:registrations => 'registrations'}
      
  root :to => "home#index"
  
  namespace :admin do
    get '/' => 'dashboard#index'
  end
  
  namespace :manager do
    get '/' => 'dashboard#index'
  end

  resources :room_availables do
    post 'rooms_to_sell'
    post 'update_status'
  end
    
  match 'new_manager' => 'users#create', :via => :post, :as => 'create_user'
  # match 'new_manager' => 'users#create_manager', :via => :post, :as => 'new_manager'
  match 'dashboard' => "dashboard#index", :via => :get, :as => 'dashboard'
  match 'hotel_photos/:hotel_id' => "hotel_photos#create", :via => :post
  match 'hotel_photos' => "hotel_photos#destroy", :via => :delete
  match 'room_photos/:room_id' => "room_photos#create", :via => :post
  match 'room_photos' => "room_photos#destroy", :via => :delete
  match 'hotels/search' => "home#search", :via => :get
  match 'booking_detail' => "home#booking_detail", :via => :get
  match 'checkout' => "home#checkout", :via => :get
  match 'checkout_confirm' => "home#checkout_confirm", :via => :post
  match 'traveler_signin_book' => "home#traveler_signin_book", :via => :post
  match 'check_availability' => "home#check_availability", :via => :post
  match 'fetch_states' => "countries#fetch_states", :via => :post
  match 'welcome' => "home#welcome", :via => :get
  match 'add_property' => "home#add_property", :via => :post
  match 'terms_of_service' => 'home#terms_of_service', :as => :terms_of_service
  match 'privacy' => 'home#privacy', :as => :privacy
  match 'book_hotel' => 'home#book_hotel', :as => 'book_hotel'
  get '/home/subregion_options' => 'home#subregion_options'
  match 'faq' => 'home#faq', :as => :faq
  get '/home/autocomplete_hotel_name' => 'home#autocomplete_hotel_name'
  match 'arrivals' => 'dashboard#arrivals', :as => 'arrivals'  
  match 'bookings' => 'dashboard#bookings', :as => 'bookings'  
  match 'statistics' => 'dashboard#statistics', :as => 'statistics'
  match 'download_booking_data' => 'dashboard#download_booking_data', :as => 'download_booking_data'
  match 'export_in_excel' => 'dashboard#export_in_excel', :as => 'export_in_excel'
  match 'rooms_to_sell' => 'room_availables#rooms_to_sell', :as => 'rooms_to_sell'
  #match 'change_room_status' => 'room_availables#edit', :as => 'change_room_status', :method => :post
  match '/update_status' => 'room_availables#update_status', :as => 'room_available_update_status' 
  match 'copy_yearly_rates' => 'rates#copy_yearly_rates', :as => 'copy_yearly_rates'
  match 'rate_details' => 'rooms#rate_details', :as => 'rate_details'
  match '/add_room_rate_details' => 'rooms#add_room_rate_details', :as => 'add_room_rate_details'
  match '/update_room_rates' => 'rates#update_room_rates', :as => 'update_room_rates'
  match '/overview' => 'dashboard#overview', :as => 'overview'
  match '/invoice' => 'dashboard#invoice', :as => 'invoice'
  
  # resources :users, except: :create
  resources :users
  resources :hotels do
    post 'register', on: :member
  end
  resources :room_types
  resources :room_attributes
  resources :hotel_attributes
  resources :travelers
  resources :promotions
  resources :rooms
  resources :venues
  resources :cards
  resources :default_messages
  resources :availabilities
end
