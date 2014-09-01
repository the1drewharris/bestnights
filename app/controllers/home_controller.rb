class HomeController < ApplicationController
  impressionist :unique => [:ip_address]
  require 'interfax/base'
  require 'interfax/fax_item'
  require 'interfax/incoming'
  layout "traveler_basic", only: [:book_hotel, :checkout_confirm]

  autocomplete :hotel, :name
  
  def welcome
    respond_to do |format|
      format.html 
    end
  end

  def terms_of_service
    
  end

  def privacy
    
  end

  def faq
    
  end

  def contact_us
    
  end

  def about_us

  end
  
  def add_property
    begin
      p params[:manager]
      user = User.new(params[:manager])
      user.role = User::ROLE[1]
      user.status = "pending"
      user.address1 = ""
      user.city = ""
      user.country_id = ""
      user.zip = ""
      
      user.save(validate: false)
      user = user.reload
      
      p params[:hotel]
      @hotel = Hotel.new(params[:hotel])
      @hotel.user_id = user.id
      @hotel.save(:validate => false)
      @hotel = @hotel.reload
      
      if params[:hotel_attributes]
        ## add new hotel attribute to the hotel
        params[:hotel_attributes].keys.each do |hotel_attribute_id|
          HotelAttributeJoin.find_or_create_by_hotel_id_and_hotel_attribute_id(@hotel.id, hotel_attribute_id)
        end
      end
      
      room = Room.new(params[:room])
      room.hotel_id = @hotel.id
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
      
      flash[:success] = "Thank you for adding your property. Your account is now pending. You will be notified by email when your property is active."
      redirect_to edit_room_url(room.id)
    rescue ActiveRecord::RecordNotUnique => e
      flash[:errors] = "Please submit all the values in the respective sections"
      redirect_to root_url
    end
  end
 
  
  def index  
    
    # reset_session
    session[:checkin] = Date.today
    session[:checkout] = Date.today
    session[:search] = ""
    session[:roomtype] = ""

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

  def autocomplete_hotel_name
    term = params[:term]
    hotels = Hotel.where('name LIKE ? or city LIKE ?', "%#{term}%","%#{term}%" ).order(:name).all
    render :json => hotels.map { |hotel| {:value => hotel.name} }
  end
  
  def search
    logger.info"=======#{params}=22===========111212212========#{params[:search]}=============="
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
      
      logger.info"******111*****#{params[:date]}************************"
      session[:checkin] = params[:date][:checkin]  unless params[:date].nil?
      session[:checkout] = params[:date][:checkout]  unless params[:date].nil?
      session[:search] = params[:search]
      a = session[:checkout].nil? ? Time.now()+1 : session[:checkout]
      b = session[:checkin].nil? ? Time.now() : session[:checkin]
      logger.info"^^^^^^^^^^^#{session[:checkout]}^^^^^^^^^^^^^^#{session[:checkin]}^^^^^^^^^^^^^^^^^^^^^^^"
      session[:nights] = (a.to_date - b.to_date).to_i + 1
      logger.info"$$$$$$$$$#{b}$$$$$$$$$$$$#{(session[:checkout].to_date - session[:checkin].to_date).to_i}$$$$$$$$$$$$$$$$$$$$$$$$$"
      # session[:roomtype] = params[:roomtype]
      
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
    begin
    ## all room attributes in the hotel
    @hotel = Hotel.find(params[:hotel_id])
    #logger.info "=============#{params[:hotel_id]}======================="
    @room_attrs = @hotel.room_attributes
    @from_date = session[:checkin]
    @to_date = session[:checkout]
    session[:rate] = 0
    
    gon.group = session[:group] # passing rails variable to js object variable
    
    session[:hotels] = nil
    session[:hotel_id] = params[:hotel_id]
    @free = []
    @room_types = RoomType.all
    @room_types.each do |type|
      @rooms = RoomAvailable.find_by_room_type_id_and_hotel_id(type.id,params[:hotel_id])
      #logger.info "=================#{@rooms.number}==============================="
      @count = 0
      
      @free << {type.id => @rooms.nil? ? 0 : @rooms.number}
    end
    logger.info"************#{@free}*************"
    #TODO where is the room that has been booked?
    rescue ActiveRecord::RecordNotFound
      flash[:success] = "Please check the Hotel ID"
      redirect_to root_url
    end
    
    
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
    @hotel = Hotel.find(params[:hotel_id])
    session[:booking_rooms] = params
    gon.group = session[:group] # passing rails variable to js object variable
     @rooms = RoomAvailable.find_by_room_type_id_and_hotel_id(params[:room_type_id],params[:hotel_id])
      session[:total_room] = params[:total_room].to_i
      session[:room_needed] = params[:room_number].to_i
      
    session[:hotel_id] = params[:hotel_id]
    session[:room_type_id] = params[:room_type_id]
    # room = Room.find_by_hotel_id_and_room_type_id(params[:hotel_id],params[:room_type_id])
    # @Room = RoomRate.find_by_room_type_id(params[:room_type_id])
    @rates = RoomRate.where("room_type_id=? AND hotel_id=?", params[:room_type_id], params[:hotel_id])
   numbers = params[:room_number].to_i
   logger.info"****************#{session[:nights]}******************"
    if !session[:nights].nil?
      @amount = session[:rate] * session[:nights]
    else
      @amount = session[:rate]
    end
    logger.info"&&&&&&&&&&&&&&&&&#{@amount}&&&&&&&&&&&&&&&&&"
    session[:subtotal] = @amount
    session[:roomtype] = params[:room_number].to_i
  end
  
  ## POST JSON
  def traveler_signin_book    
    @traveler = Traveler.find_by_email(params[:email])
    session[:traveler] = @traveler
    if @traveler and @traveler.valid_password?(params[:password])
      session[:traveler_id] = @traveler.id
      redirect_to book_hotel_path(:traveler_id => @traveler.id)
    else
      flash[:success] = "Wrong Credential"
      redirect_to travelers_login_path
    end
  end

  def book_hotel
    unless current_traveler
      @traveler = Traveler.find(session[:traveler_id])
    else
      @traveler = current_traveler
    end
      session[:traveler] = @traveler 
  end
  
  ## POST
  def checkout_confirm
    @amount = 0
    @hotel = Hotel.find(session[:hotel_id])
    unless current_traveler
      @traveler = Traveler.find_by_email(params[:email])  
      unless @traveler
        @traveler = Traveler.new(params[:traveler])
        @card_number = params[:credit_card_number].blank? ? "" : params[:credit_card_number]
        @card_type = params[:credit_card_type].blank? ? "" : params[:credit_card_type]
        @ccv = params[:ccv].blank? ? "" : params[:ccv]
        @card_expiry = params[:credit_card_expiry_date].blank? ? "" : params[:credit_card_expiry_date]
        if @traveler.save
          sign_in @traveler
        else     
          flash[:errors] = @traveler.errors.full_messages
          redirect_to checkout_path(:hotel_id => @hotel.id, :room_type_id => session[:room_type_id])
        end
      end
      @card_number = @traveler.credit_card_number
      @card_type = @traveler.credit_card_type
      @ccv = @traveler.credit_card_number
      @card_expiry = @traveler.credit_card_expiry_date
    else
      @traveler = current_traveler
      @card_number = @traveler.credit_card_number
      @card_type = @traveler.credit_card_type
      @ccv = @traveler.credit_card_number
      @card_expiry = @traveler.credit_card_expiry_date
    end
    @country = Carmen::Country.coded(@traveler.country_id )
    @subregion = @country.subregions.coded(@traveler.state_id)

    logger.info"**********************#{session[:checkin]}**************#{session[:checkout]}***********"
    from_date = session[:checkin]
    to_date = session[:checkout]
    a = session[:checkout].nil? ? Time.now()+1 : session[:checkout]
    b = session[:checkin].nil? ? Time.now() : session[:checkin]

    number_nights = ((a.to_date - b.to_date).to_i) + 1
    room_ids = []
    room = Room.find_by_hotel_id_and_room_type_id(session[:hotel_id], session[:room_type_id])
   
    @Room = RoomRate.find_by_room_type_id(session[:room_type_id])
    numbers = session[:roomtype].to_i
    @find_room_type = RoomType.find_by_id(session[:roomtype])
    @room_type = @find_room_type.room_type
    # number_nights.times do |t|
    #   @amount = @amount + (a.to_date.advance(:days => t).strftime("%A").downcase).to_f
    # end
    @rates = RoomRate.where("room_type_id=? AND hotel_id=?", params[:room_type_id], params[:hotel_id])
   numbers = params[:room_number].to_i
   logger.info"****************#{session[:nights]}******************"
    if !session[:nights].nil?
      @amount = session[:rate] * session[:nights]
    else
      @amount = session[:rate]
    end
    
    room_ids.push(room.id)
    @room_amount = room.price.to_f
    session[:subtotal] = @amount

    @checkin = session[:checkin]
    @checkout = session[:checkout]
     numbers = session[:roomtype].to_i
        @room1 = Room.find_by_hotel_id_and_room_type_id(session[:hotel_id], session[:room_type_id])
        #@room_rate = RoomRate.find_by_room_id_and_room_type_id(@room1.id, session[:room_type_id])
        #@rooms = RoomAvailable.find_by_room_type_id_and_hotel_id(session[:room_type_id],session[:hotel_id])
        @rooms = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", @room1.room_sub_type_id,session[:hotel_id])

        number_nights.times do |t|
           @amount = @amount + @room1.price.to_f
        end

        @amount = @amount * numbers

        #Bookings data saving
        numbers = session[:roomtype].to_i
        numbers.times do |n|
           booking = Booking.new(hotel_id: @room1.hotel.id, room_id: @room1.id, from_date: from_date, to_date: to_date, 
                        adults: numbers, traveler_id: @traveler.id, night_number: number_nights, price: @amount)
        
          booking.save
        end
        # This cookies are used for Fax contant save in html format
        cookies[:name] = @traveler.name
        cookies[:hotel_name] = @hotel.name
        cookies[:address] = @traveler.address1
        cookies[:city] = @traveler.city
        cookies[:zip] = @traveler.zip
        cookies[:phone_number] = @traveler.phone_number
        cookies[:email] = @traveler.email
        cookies[:cardtype] = @traveler.credit_card_type
        cookies[:card_number] = @traveler.credit_card_number
        cookies[:ccv] = @traveler.ccv
        cookies[:credit_card_expiry_date] = @traveler.credit_card_expiry_date
        @get_bookings = Booking.where(traveler_id: @traveler.id, hotel_id: room.hotel.id).order("created_at DESC").limit(1)
        @get_bookings.each do |booking|
          cookies[:reservation_number] = booking.id
          cookies[:arrival_date] = booking.from_date
          cookies[:departure_date] = booking.to_date
          cookies[:night_number] = booking.night_number
          cookies[:adults] = booking.adults
          cookies[:remarks] = booking.message
          cookies[:created_at] = booking.created_at
        end
        cookies[:total_price] = @amount
        cookies[:room_type] = room.room_type.room_type 
        cookies[:amount] = @amount 
      
    if book(@traveler, @amount, @card_number, @ccv, @card_type, @hotel, @checkin, @checkout, session[:room_needed], @room_type )
      ## Create booking record and availability record
       @rate = @room1.price.to_f
        # numbers = session[:roomtype].to_i
        # numbers.times do |n|
        #    booking = Booking.new(hotel_id: @room1.hotel.id, room_id: @room1.id, from_date: from_date, to_date: to_date, 
        #                 adults: numbers, traveler_id: @traveler.id, night_number: number_nights, price: @amount)
        
        #   booking.save
        # end
        @rooms.each do |room|
          unless room.from_date == from_date.to_date && room.to_date == to_date.to_date
            if (room.from_date..room.to_date).include?(from_date.to_date)
              if room.from_date < from_date.to_date.advance(days: -1)
                logger.info"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
                create_sell(room.room_sub_type_id,session[:hotel_id],room.room_type_id,room.from_date,from_date.to_date.advance(days: -1),room.number)
              end
              logger.info"^^^^#{session[:total_room]}^^^^^^^^^^^^^^^^#{session[:room_needed]}^^^^^^^^^"
              create_sell(room.room_sub_type_id,session[:hotel_id],room.room_type_id,from_date.to_date,to_date.to_date,session[:total_room].to_i - session[:room_needed].to_i)
              if (room.from_date..room.to_date).include?(to_date.to_date)
                create_sell(room.room_sub_type_id,session[:hotel_id],room.room_type_id,to_date.to_date.advance(days: 1),room.to_date,room.number)
              end
              room.destroy
            end
          else
            room.number = room.number
            room.save
          end
        end
        #@rooms.number = session[:total_room].to_i - session[:room_needed].to_i
        #@rooms.save
        (from_date..to_date).each do |date|
          if availability = Availability.find_by_room_id_and_this_date(@room1.id, date)
            availability.update_attributes(count: availability.count - numbers)
          else
            Availability.create(this_date: date, starting_inventory: @room1.starting_inventory, count: room.starting_inventory - numbers,
                                room_id: @room1.id)
          end
        end
        @booking = Booking.where(:traveler_id => @traveler.id, :hotel_id =>  @hotel)
        @numbers = numbers

        @latest_booked = Booking.where(traveler_id: @traveler.id, hotel_id: room.hotel.id).order("created_at DESC").limit(1)
        logger.info"&&&&&#{@amount}&&&&&&&&&&#{@latest_booked.inspect}&&&&&222222&&&&#{@card_number}&&&"
        @price = @amount / session[:nights]
        @fax_email = FaxMailer.hotel_booking_mail(@traveler, @amount, @card_number, @ccv, @card_type, @hotel, @checkin, @checkout, numbers, @latest_booked, @room1,@rate,@card_expiry, request.protocol,request.host_with_port, number_nights, @price).deliver
        @fax_email_to_hotel = FaxMailer.email_to_hotel(@traveler, @amount, @card_number, @ccv, @card_type, @hotel, @checkin, @checkout, room_ids, @latest_booked, @room1, @card_expiry, request.protocol,request.host_with_port, numbers, number_nights, @price).deliver
    else
      flash[:errors] = ["Your booking failed!"]
      redirect_to checkout_path
    end        
  end
  
  def subregion_options
    render partial: 'test'
  end
  
  
  private
  
  def book(traveler, amount, cardnumber,ccv, cardtype, hotel, checkin, checkout, room_ids, room_type)
    logger.info"@@@@@@@@@@#{traveler.inspect}@@@@@@#{amount}@@@@@@@@@@@@#{cardnumber}@@@@@@@@#{cardtype}@@@@@@#{checkin}@@@@@@#{checkout}@"
    
    #TODO make this work with the fax service
    @disclaimer = CGI::unescape("Disclaimer"+"\n"+"* A confirmation has been sent to the guest with all of the booking details"+"\n"+"* It is your duty , as the booking property, to safeguard this fax and the guests credit card info in a secure way that follows your company's security policies")
    File.open("#{Rails.root.to_s}/public/"+traveler.id.to_s+'.txt', 'wb') do|f|
      f.write('Traveler Name'+':'+traveler.name+"\n"+'Traveler Email'+':'+traveler.email+"\n"+'Card Number'+':'+traveler.credit_card_number+"\n"+'Card Type'+':'+traveler.credit_card_type+"\n"+'Address'+':'+traveler.address1+"\n"+'Amount'+':'+"#{amount}"+"\n"+'Checkin Date'+':'+checkin.to_s+"\n"+'Checkout Date'+':'+checkout.to_s+"\n"+'Room Number'+':'+"#{room_ids}"+"\n"+'Room Type'+':'+"#{room_type}"+"\n"+@disclaimer)
    end
    results = []
    chars = 0
    File.open("#{Rails.root.to_s}/public/"+traveler.id.to_s+'.txt', 'r').each { |line| results << line }
      results.each do |line|
      chars += line.length
    end
  
   # @fax_result = SOAP::WSDLDriverFactory.new("https://ws-sl.fax.tc/Outbound.asmx?WSDL").create_rpc_driver.SendCharFax("Username" => "bestnights","Password" => "@BestN1ghts","FileType" => "TXT","FaxNumber"=> "18444942378","Data" => "#{results[0]+"\n"+results[1]+"\n"+results[2]+"\n"+results[3]+"\n"+results[4]+"\n"+results[5]+"\n"+results[6]+"\n"+results[7]+"\n"+results[8]+"\n"+results[9]}")
   #  logger.info"@@@@@@@@@@@@@@@@@@@@@@@#{@fax_result.inspect}@@@@@@@@@@@@@@@@@@@@@@@@"
   # File.delete("#{Rails.root.to_s}/public/"+traveler.id.to_s+".txt")
   # unless @fax_result["SendCharFaxResult"].include? "-"
   #  TravelerPayment.create(amount: amount, traveler_id: traveler.id)
   # else
   #  flash[:notice] = "Hotel not booked due wrong params"
   #  redirect_to root_path
   # end
  end
end
