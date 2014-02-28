class HomeController < ApplicationController
  
  def index  
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
    @grouped_hotels = hotels.group_by { |d| d[:city].downcase} 
    
    ## the latest hotels who just joined
    @latest_joined_hotels = Hotel.latest_joined_hotels
    
    @from_date = session[:checkin]
    @to_date = session[:checkout]
  end
  
  def search
    
    if request.xhr?
      # hotels = session[:hotels]
      hotels = Hotel.all      
      hotel = HotelSearch.new(params)
      @hotels = hotel.filter(hotels)  
    else
      @search = params[:search] || session[:search]
      @startdate = params[:date][:checkin] unless params[:date].nil? || session[:checkin]
      @enddate = params[:date][:checkout]  unless params[:date].nil? || session[:checkout]
      
      reset_session
      
      session[:checkin] = params[:date][:checkin]  unless params[:date].nil?
      session[:checkout] = params[:date][:checkout]  unless params[:date].nil?
      session[:search] = params[:search]
      
      hotel = HotelSearch.new(params)
      
      @hotels = hotel.search
      # @hotels = Hotel.all
      
      # session[:hotels] = @hotels
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
    
    session[:hotels] = nil
    session[:hotel_id] = params[:hotel_id]
  end
  
  def checkout
    @traveler = Traveler.new
    
    session[:booking_rooms] = params
    
    # @room_id = params[:room_id]
    # @number = params[:number]
    # session[:room_id] = params[:room_id]
    # session[:number] = params[:number]
  end
  
  ## POST JSON
  def traveler_signin_book    
    @traveler = Traveler.find_by_email(params[:email])
    unless @traveler.valid_password?(params[:password])
      @traveler = Traveler.new
    end
    
    render :json => @traveler
  end
  
  ## POST
  def checkout_confirm
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
    
    amount = 0;
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
        p "booking save start"
        booking = Booking.new(hotel_id: room.hotel.id, room_id: room.id, from_date: from_date, to_date: to_date, 
                        adults: numbers, traveler_id: @traveler.id)
        p booking
        p 'ok' if booking.save
        p booking.errors
        p "booking save end"
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
      flash[:errors] = ["Your booking was failed!"]
      redirect_to :back and return  
    end        
  end
  
  
  
  private
  
  def book(traveler, amount, cardnumber, expiration)
        
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
  end
end
