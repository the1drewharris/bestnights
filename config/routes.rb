Bestnights::Application.routes.draw do
  

  resources :positions

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
  devise_for :travelers
      
  root :to => "home#index"
  
  namespace :admin do
    get '/' => 'dashboard#index'
  end
  
  namespace :manager do
    get '/' => 'dashboard#index'
  end

  resources :room_availables do
    post 'rooms_to_sell'
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
  match 'checkout_confirm' => "home#checkout_confirm"
  match 'traveler_signin_book' => "home#traveler_signin_book", :via => :post
  match 'check_availability' => "home#check_availability", :via => :post
  match 'fetch_states' => "countries#fetch_states", :via => :post
  match 'welcome' => "home#welcome", :via => :get
  match 'add_property' => "home#add_property", :via => :post
  match 'terms_of_service' => 'home#terms_of_service', :as => :terms_of_service
  match 'privacy' => 'home#privacy', :as => :privacy
  match 'book_hotel/:traveler_id' => 'home#book_hotel', :as => 'book_hotel'
  get '/home/subregion_options' => 'home#subregion_options'
  get '/hotels/subregion_options' => 'home#subregion_options'
  get '/users/subregion_options' => 'home#subregion_options'
  match 'faq' => 'home#faq', :as => :faq
  get '/home/autocomplete_hotel_name' => 'home#autocomplete_hotel_name'
  match 'arrivals' => 'dashboard#arrivals', :as => 'arrivals'  
  match 'bookings' => 'dashboard#bookings', :as => 'bookings'  
  match 'statistics' => 'dashboard#statistics', :as => 'statistics'
  match 'download_booking_data' => 'dashboard#download_booking_data', :as => 'download_booking_data'
  match 'export_in_excel' => 'dashboard#export_in_excel', :as => 'export_in_excel'
  match 'rooms_to_sell' => 'room_availables#rooms_to_sell', :as => 'rooms_to_sell'
  #match 'change_room_status' => 'room_availables#edit', :as => 'change_room_status', :method => :post
  match '/update_status' => 'room_availables#update_status', :as => 'room_available_update_status', :via => :post
  match 'status' => 'room_availables#status', :as => 'room_availables_status'
  match 'copy_yearly_rates' => 'rates#copy_yearly_rates', :as => 'copy_yearly_rates'
  match 'rate_details' => 'rooms#rate_details', :as => 'rate_details'
  match '/add_room_rate_details' => 'rooms#add_room_rate_details', :as => 'add_room_rate_details'
  match '/update_room_rates' => 'rates#update_room_rates', :as => 'update_room_rates'
  match '/overview' => 'dashboard#overview', :as => 'overview'
  match '/invoice' => 'dashboard#invoice', :as => 'invoice'
  match '/status/:id' => 'dashboard#status', :as => 'status'
  match '/booking_status/:id' => 'dashboard#booking_status', :as => 'booking_status'
  match '/finance' => "dashboard#finance", :as => 'finance'
  match 'reservation_statements' => "dashboard#reservation_statements", :as => 'reservation_statements'
  match 'my_hotels' => "dashboard#my_hotels", :as => 'my_hotels'
  match 'download_reservation_data' => "dashboard#download_reservation_data", :as => 'download_reservation_data'
  match 'export_reservation_in_excel' => "dashboard#export_reservation_in_excel", :as => 'export_reservation_in_excel'
  match 'finance_info' => "dashboard#finance_info", :as => 'finance_info'
  match 'invoicing_details' => "dashboard#invoicing_details", :as => 'invoicing_details'
  match 'find_room_details' => "dashboard#find_room_details", :as => 'find_room_details'
  match 'download_reservation_data_month' => "dashboard#download_reservation_data_month", :as => 'download_reservation_data_month', :via => :get
  match 'download_statement_data_month' => "dashboard#download_statement_data_month", :as => 'download_statement_data_month'
  match 'about' => "home#about_us", :as => 'about'
  match 'travelers_login' => "travelers#travelers_login", :as => 'travelers_login'
  match 'traveler_login_create' => "travelers#traveler_login_create", :as => 'traveler_login_create', :via => :post
  match 'traveler' => "travelers#show", :as => 'traveler_detail', :via => :get
  match 'rates/search/:room_type_id' => "rates#search", :as => 'rate_search'
  match 'traveler_create' => "travelers#create", :as => :travelers_create, :via => :post
  match 'traveler_details/:id' => "travelers#show_traveler", :as => :show_traveler, :via => :get
  match 'booking_history/:id' => "travelers#booking_history", :as => :booking_history, :via => :get
  match 'cancel_booking/:book_id' => "travelers#cancel_booking", :as => :cancel_booking, :via => :get
  match '/get_sub_type' => "rooms#get_sub_type", :as => :get_sub_type, :via => :get
  match '/reserve_status/:id' => 'dashboard#reserve_status', :as => 'reserve_status'
  match '/register' => 'home#landing', :as => 'register'

  # resources :users, except: :create
  resources :users
  resources :hotels do
    post 'register', on: :member
    get  'confirm'
    get  'make_pending' 
    get  'edit_commission_rate'
  end
  resources :room_types
  resources :room_sub_types
  resources :room_attributes
  resources :hotel_attributes
  resources :travelers do 
    get 'edit_traveler', on: :member
    get 'cancel_booking'
    get 'change_password', on: :member
  end
  resources :promotions
  resources :rooms
  resources :venues
  resources :cards
  resources :default_messages
  resources :availabilities
  resources :contact_people
end
