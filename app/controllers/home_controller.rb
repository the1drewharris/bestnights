class HomeController < ApplicationController
  
  def welcome
    respond_to do |format|
      format.html 
    end
  end
  
  def add_property
    p params[:manager]
    user = User.new(params[:manager])
    user.role = User::ROLE[1]
    user.status = "pending"
     
    user.save(:validate => false)
    user = user.reload
    
    p params[:hotel]
    hotel = Hotel.new(params[:hotel])
    hotel.user_id = user.id
    hotel.save(:validate => false)
    hotel = hotel.reload
    
    if params[:hotel_attributes]
      ## add new hotel attribute to the hotel
      params[:hotel_attributes].keys.each do |hotel_attribute_id|
        HotelAttributeJoin.find_or_create_by_hotel_id_and_hotel_attribute_id(hotel.id, hotel_attribute_id)
      end
    end
    
    room = Room.new(params[:room])
    room.hotel_id = hotel.id
    room.save(:validate => false)
    room = room.reload    
    
    if params[:room_attributes]
      ## add new hotel attribute to the hotel
      params[:room_attributes].keys.each do |room_attribute_id|
        RoomAttributeJoin.find_or_create_by_room_id_and_room_attribute_id(room.id, room_attribute_id)
      end      
    end
    
    AdminMailer.added_hotel_request(user).deliver
    
    sign_in(:user, user)
    
    redirect_to new_hotel_url
  end
 
  
  def index  
    
    reset_session
    
    latest_rooms = Room.latest_rooms  
    
    ## Group rooms by hotel id
    grouped_rooms = latest_rooms.group_by { |d| d[:hotel_id]} 
    
    ## Get hotels of the rooms
    hotels = []
    grouped_rooms.each do |room|
      hotel_id = room.first
      hotels << Hotel.find(hotel_id)
    end
        
    ## Group the hotels by city
    #TODO Need a count here too to use in the view
    @grouped_hotels = hotels.group_by { |d| d[:city].downcase} 
    
    ## the latest hotels who just joined
    @latest_joined_hotels = Hotel.latest_joined_hotels
    
    gon.group = session[:group] # passing rails variable to js object variable
    
  end
  
  def search
    
    if request.xhr?
      # hotels = session[:hotels]
      hotels = [] 
      session[:hotel_ids].each do |hotel_id|
        hotels << Hotel.find(hotel_id)
      end     
      hotel = HotelSearch.new(params)
      @hotels = hotel.filter(hotels)  
    else
      @search = params[:search] || session[:search]
      @startdate = params[:date][:checkin] unless params[:date].nil? || session[:checkin]
      @enddate = params[:date][:checkout]  unless params[:date].nil? || session[:checkout]
      
      # reset_session
      
      session[:checkin] = params[:date][:checkin]  unless params[:date].nil?
      session[:checkout] = params[:date][:checkout]  unless params[:date].nil?
      session[:search] = params[:search]
      session[:roomtype] = params[:roomtype]
      
      session[:group] = params[:group]
      gon.group = session[:group] # passing rails variable to js object variable
      
      hotel = HotelSearch.new(params)
      
      @hotels = Hotel.search(params[:search])
      # @hotels = Hotel.all
      
      session[:hotel_ids] = []
      @hotels.each do |h|
        session[:hotel_ids] << h.id
      end
    end
    
    respond_to do |format|
      format.html
      format.json
    end
    
  end
  
  def booking_detail
    
    @hotel = Hotel.find(params[:hotel_id])
    
    ## all room attributes in the hotel
    @room_attrs = @hotel.room_attributes
    @from_date = session[:checkin]
    @to_date = session[:checkout]
    
    gon.group = session[:group] # passing rails variable to js object variable
    
    session[:hotels] = nil
    session[:hotel_id] = params[:hotel_id]
  end
  
  ## POST JSON
  def check_availability
    
    hotel = Hotel.find(session[:hotel_id])
    checkin = params[:checkin]
    checkout = params[:checkout]
    roomtype = params[:roomtype]
    
    ## set room numbers with room type
    if roomtype == "1"
      room_numbers = 1
    elsif roomtype == "2"
      room_numbers = 2
    elsif roomtype == "3"
      room_numbers = params[:roomqty]
    end
    
    ## set bed numbers array with group type
    bed_numbers = []
    if roomtype == "3"
      params[:rooms].each do |room_beds|
        bed_numbers << room_beds.last.collect {|s| s.to_i}.sum
      end
    end
    
    ## check availability of the hotel
    result = hotel.available?(checkin, checkout, room_numbers, bed_numbers)
    
    render :json => result
  end
  
  def checkout
    @traveler = Traveler.new
    @hotel = Hotel.find(session[:hotel_id])
    session[:booking_rooms] = params
    gon.group = session[:group] # passing rails variable to js object variable
    
    @amount = 0
    session[:booking_rooms][:number].each do |room_number|
      room = Room.find(room_number.first)
      numbers = room_number.last.to_i
      @amount = @amount + room.price.to_f * numbers
    end
    
  end
  
  ## POST JSON
  def traveler_signin_book    
    @traveler = Traveler.find_by_email(params[:email])
    
    if @traveler and @traveler.valid_password?(params[:password])
      render :json => @traveler, :status => 200
    else
      render :nothing => true, :status => 404
    end
    
  end
  
  ## POST
  def checkout_confirm
    
    @hotel = Hotel.find(session[:hotel_id])
    
    if params[:traveler][:email] != params[:emailconfirm]
      flash[:errors] = ["confirm your email address"]
      redirect_to :back and return
    end    
    
    @traveler = Traveler.find_by_email(params[:traveler][:email])
    
    unless @traveler
      @traveler = Traveler.new(params[:traveler])
    end
    
    from_date = session[:checkin]
    to_date = session[:checkout]
    
    amount = 0
    session[:booking_rooms][:number].each do |room_number|
      room = Room.find(room_number.first)
      numbers = room_number.last.to_i
      amount = amount + room.price.to_f * numbers
    end
    
    expiryDate = params[:ccexpirym] + params[:ccexpiryy]
    
    if book(@traveler, amount, params[:ccnumber], expiryDate)
      
      unless @traveler.save
        flash[:errors] = @traveler.errors
        redirect_to :back and return
      end
      
      ## Create booking record and availability record
      session[:booking_rooms][:number].each do |room_number|
        room = Room.find(room_number.first)
        numbers = room_number.last.to_i
        
        booking = Booking.new(hotel_id: room.hotel.id, room_id: room.id, from_date: from_date, to_date: to_date, 
                        adults: numbers, traveler_id: @traveler.id)
        
        booking.save
        
        (from_date..to_date).each do |date|
          if availability = Availability.find_by_room_id_and_this_date(room.id, date)
            availability.update_attributes(count: availability.count - numbers)
          else
            Availability.create(this_date: date, starting_inventory: room.starting_inventory, count: room.starting_inventory - numbers,
                                room_id: room.id)
          end
        end
      end
    else
      flash[:errors] = ["Your booking failed!"]
      redirect_to :back and return  
    end        
  end
  
  
  
  private
  
  def book(traveler, amount, cardnumber, expiration)
    
    #TODO make this work with the fax service
    
=begin
     
    transaction = AuthorizeNet::ARB::Transaction.new('98dR8Lw23dG', '7Eb688x2zqDmQ9Ke', :gateway => :sandbox)
    subscription = AuthorizeNet::ARB::Subscription.new(
        :name => "Bestnight Booking",
        :length => 1,
        :unit => :month,
        :start_date => Date.today,
        :total_occurrences => 9999,
        :amount => amount,
        :invoice_number => "123456789",
        :description => "Booking",
        :credit_card => AuthorizeNet::CreditCard.new(cardnumber, expiration),
        :billing_address => AuthorizeNet::Address.new(
          :first_name => traveler.firstname, 
          :last_name => traveler.lastname, 
          :street_address => traveler.address1, 
          :city => traveler.city,
          :state => traveler.state.state_province,
          :zip => traveler.zip,
          :email => traveler.email,
          :country => traveler.country.country )
    )
    
    response = transaction.create(subscription)
    
    if response.success?
      TravelerPayment.create(transactionid: response.subscription_id, amount: amount, traveler_id: traveler.id)
      return true
    else
      return false
    end
    
=end

  end


end
