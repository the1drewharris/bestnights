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
      
      session[:checkin] = params[:date][:checkin]  unless params[:date].nil?
      session[:checkout] = params[:date][:checkout]  unless params[:date].nil?
      session[:search] = params[:search]
      a = session[:checkout]
      b = session[:checkin]
      session[:nights] = (a.to_date - b.to_date).to_i
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
    @room_attrs = @hotel.room_attributes
    @from_date = session[:checkin]
    @to_date = session[:checkout]
    
    gon.group = session[:group] # passing rails variable to js object variable
    
    session[:hotels] = nil
    session[:hotel_id] = params[:hotel_id]
    @free = []
    @room_types = RoomType.all
    @room_types.each do |type|
      @rooms = Room.where("room_type_id=? AND hotel_id=?",type.id,params[:hotel_id])
      @count = 0
      @rooms.each do |room|
        @booking = Booking.find_by_hotel_id_and_room_id(room.id,session[:hotel_id])
        if !@booking.nil?
          @count += 1
        end
      end
      @free << {type.id => @rooms.count - @count}
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
    
    # @amount = 0
    # session[:booking_rooms][:number].each do |room_number|
    #   logger.info"&&&&&&&&&#{room_number.first}&&&&&&&&&&&&&&&&&#{room_number.last}&&&&&&&&&&&&&&&&"
    #   room = Room.find(room_number.first)
    #   numbers = room_number.last.to_i
    #   @amount = @amount + room.price.to_f * numbers
    # end
    # session[:subtotal] = @amount
    session[:hotel_id] = params[:hotel_id]
    session[:room_id] = params[:room_id]
    room = Room.find_by_hotel_id_and_id(params[:hotel_id],params[:room_id])
    numbers = params[:room_number].to_i
    if !session[:nights].nil?
      @amount = (room.price.to_f * numbers) * session[:nights]
    else
      @amount = room.price.to_f * numbers
    end
    session[:subtotal] = @amount
    session[:roomtype] = params[:room_number].to_i
  end
  
  ## POST JSON
  def traveler_signin_book    
    @traveler = Traveler.find_by_email(params[:email])
    session[:traveler_id] = @traveler.id
    logger.info"===========#{(params[:password]).inspect}=======#{@traveler.valid_password?(params[:password])}===========#{session[:booking_rooms][:number]}======="
    if @traveler and @traveler.valid_password?(params[:password])
      redirect_to book_hotel_path
      # render :json => @traveler, :status => 200
    else
      redirect_to root_url
    end
    
  end

  def book_hotel
    @traveler = Traveler.find(session[:traveler_id])
    session[:traveler] = @traveler 
  end
  
  ## POST
  def checkout_confirm
    @hotel = Hotel.find(session[:hotel_id])
    #logger.info"=============22=#{params[:emailconfirm]}=22===========#{params[:traveler][:email]}========="
    if params[:traveler] && params[:traveler][:email] != params[:emailconfirm]
      flash[:errors] = ["confirm your email address"]
      redirect_to :back and return
    end    
    unless current_traveler
      @traveler = Traveler.find_by_email(params[:email])    
      unless @traveler
        @traveler = Traveler.new(params[:traveler])
        if @traveler.save
        sign_in @traveler
      else         
          flash[:errors] = @traveler.errors
          redirect_to :back and return
        end
      end
    else
      @traveler = current_traveler
    end
    @country = Carmen::Country.coded(@traveler.country_id )
    @subregion = @country.subregions.coded(@traveler.state_id)

    from_date = session[:checkin]
    to_date = session[:checkout]
    a = session[:checkout]
    b = session[:checkin]

    number_nights = ((a.to_date - b.to_date).to_i) + 1 
    room_ids = []
    room = Room.find_by_hotel_id_and_id(session[:hotel_id], session[:room_id])
    numbers = session[:roomtype].to_i
    if !session[:nights].nil?
      @amount = (room.price.to_f * numbers) * session[:nights]
    else
      @amount = room.price.to_f * numbers
    end
    room_ids.push(room.id)
    session[:subtotal] = @amount

    @checkin = session[:checkin]
    @checkout = session[:checkout]

puts "===============#{@traveler.inspect}"
    if book(@traveler, session[:subtotal], params[:ccnumber], params[:ccv], params[:cardtype], @hotel, @checkin, @checkout, room_ids )
      ## Create booking record and availability record

        room = Room.find_by_hotel_id_and_id(session[:hotel_id], session[:room_id])
        numbers = session[:roomtype].to_i
        
        booking = Booking.new(hotel_id: room.hotel.id, room_id: room.id, from_date: from_date, to_date: to_date, 
                        adults: numbers, traveler_id: @traveler.id, night_number: number_nights)
        
        booking.save
        logger.info"@@@@@@@@@@@@@@@#{from_date}@@@@@@@@@@@@@@@@@@@@#{to_date}@@@@@@@@@@"
        (from_date..to_date).each do |date|
          if availability = Availability.find_by_room_id_and_this_date(room.id, date)
            availability.update_attributes(count: availability.count - numbers)
          else
            Availability.create(this_date: date, starting_inventory: room.starting_inventory, count: room.starting_inventory - numbers,
                                room_id: room.id)
          end
        end
        @booking = Booking.where(:traveler_id => @traveler.id, :hotel_id =>  @hotel)
        @numbers = numbers
        @latest_booked = Booking.where(traveler_id: @traveler.id, hotel_id: room.hotel.id).order("created_at DESC").limit(1)
        @fax_email = FaxMailer.hotel_booking_mail(@traveler, session[:subtotal], params[:ccnumber], params[:ccv], params[:cardtype], @hotel, @checkin, @checkout, room_ids, @latest_booked, room).deliver
        @fax_email_to_hotel = FaxMailer.email_to_hotel(@traveler, session[:subtotal], params[:ccnumber], params[:ccv], params[:cardtype], @hotel, @checkin, @checkout, room_ids, @latest_booked, room).deliver
        logger.info"====2222222222222222222==========#{@fax_email}=============="
    else
      flash[:errors] = ["Your booking failed!"]
      redirect_to :back and return  
    end        
  end
  
  def subregion_options
    render partial: 'test'
  end
  
  
  private
  
  def book(traveler, amount, cardnumber,ccv, cardtype, hotel, checkin, checkout, room_ids)
    logger.info"@@@@@@@@@@#{traveler.inspect}@@@@@@#{amount}@@@@@@@@@@@@#{cardnumber}@@@@@@@@#{cardtype}@@@@@@#{checkin}@@@@@@#{checkout}@"
    
    #TODO make this work with the fax service
    @disclaimer = CGI::unescape("Disclaimer"+"\n"+"* A confirmation has been sent to the guest with all of the booking details"+"\n"+"* It is your duty , as the booking property, to safeguard this fax and the guests credit card info in a secure way that follows your company's security policies")
    File.open("#{Rails.root.to_s}/public/"+traveler.id.to_s+'.txt', 'wb') do|f|
      f.write('Traveler Name'+':'+traveler.name+"\n"+'Traveler Email'+':'+traveler.email+"\n"+'Card Number'+':'+traveler.credit_card_number+"\n"+'Card Type'+':'+traveler.credit_card_type+"\n"+'Address'+':'+traveler.address1+"\n"+'Amount'+':'+"#{amount}"+"\n"+'Checkin Date'+':'+checkin.to_s+"\n"+'Checkout Date'+':'+checkout.to_s+"\n"+'Room Number'+':'+"#{room_ids.each { |r| puts r }}"+"\n"+@disclaimer)
    end
    results = []
    chars = 0
    File.open("#{Rails.root.to_s}/public/"+traveler.id.to_s+'.txt', 'r').each { |line| results << line }
      results.each do |line|
      chars += line.length
    end
    #File.delete("#{Rails.root.to_s}/public/"+traveler.id.to_s+".txt")
  
    @fax_result = SOAP::WSDLDriverFactory.new("https://ws-sl.fax.tc/Outbound.asmx?WSDL").create_rpc_driver.SendCharFax("Username" => "bestnights","Password" => "@BestN1ghts","FileType" => "TXT","FaxNumber"=> "15874090031","Data" => "#{results[0]+"\n"+results[1]+"\n"+results[2]+"\n"+results[3]+"\n"+results[4]+"\n"+results[5]+"\n"+results[6]+"\n"+results[7]+"\n"+results[8]}")
    logger.info"@@@@@@@@@@@@@@@@@@@@@@@#{@fax_result.inspect}@@@@@@@@@@@@@@@@@@@@@@@@"
    File.delete("#{Rails.root.to_s}/public/"+traveler.id.to_s+".txt")
    unless @fax_result["SendCharFaxResult"].include? "-"
      TravelerPayment.create(amount: amount, traveler_id: traveler.id)
    else
      flash[:notice] = "Hotel not booked due wrong params"
      redirect_to root_path
    end
  end
end
