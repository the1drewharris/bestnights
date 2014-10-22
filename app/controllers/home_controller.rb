class HomeController < ApplicationController
  impressionist :unique => [:ip_address]
  require 'interfax/base'
  require 'interfax/fax_item'
  require 'interfax/incoming'
  layout "traveler_basic", only: [:book_hotel, :checkout_confirm, :checkout]

  autocomplete :hotel, :name
  
  def welcome
    respond_to do |format|
      format.html 
    end
  end

  def terms_of_service
    @term = Term.first
  end

  def privacy
    @privacy = PrivacyPolicy.first
  end

  def faq
    @faq = Faq.first
  end

  def contact_us
   @contact = SiteContact.first 
  end

  def about_us
    @about_us = AboutU.first
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
      
      flash[:success] = "Kindest Regards for adding your property. Your account is now pending. You will be notified by email when your property is active."
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
    @hotels = Hotel.where(status: "active").order("created_at DESC").limit(5)
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
      
      #HotelSearch doing here(for teh pagination purpose) instead of search in model fo
      if !params[:search].blank?
        @hotels = Hotel.where("status = ? and (name LIKE ? or city LIKE ?)", "active", params[:search], params[:search]).paginate(:page => params[:page], :per_page => 5, :order => "name")
      else
        @hotels = Hotel.where("status = ?", "active").paginate(:page => params[:page], :per_page => 5, :order => "name")
      end

      
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
    @hotel_view = HotelView.new
    @hotel_view.hotel_id = @hotel.id
    @hotel_view.save
    @room_attrs = @hotel.room_attributes
    if cookies[:intime]
      session[:checkin] = cookies[:intime]
    end
    if cookies[:outtime]
      session[:checkout] = cookies[:outtime]
    end
    @from_date = session[:checkin]
    @to_date = session[:checkout]
    session[:rate] = 0
    session[:room_rate] = []
    session[:price] = {}
    
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
    @hotel.rooms.each_with_index do |room, index|
      @rates = RoomRate.where("room_sub_type_id=? AND hotel_id=?", room.room_sub_type_id, @hotel.id)
      unless @rates.empty?
        @rates.each do |rate|
          if !rate.blank?
            ((session[:checkout].to_date - session[:checkin].to_date).to_i).times do |day| 
              if (rate.from_date..rate.to_date).cover?(session[:checkin].to_date.advance(days: day))
                session[:rate] += rate.price
              end
            end
          end
        end
      end
      session[:room_rate] << session[:rate]
      session[:price].merge!("#{room.room_sub_type_id}" => session[:rate])
      logger.info"______________#{session[:price]}_________________"
      session[:rate] = 0
    end
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
    @available_flag = 0
    @status_flag = 0
    @checkin_flag = 0
    @checkout_flag = 0
    @traveler = Traveler.new
    @hotel = Hotel.find(params[:hotel_id])
    session[:booking_rooms] = params
    gon.group = session[:group] # passing rails variable to js object variable
     #@rooms = RoomAvailable.find_by_room_type_id_and_hotel_id(params[:room_type_id],params[:hotel_id])
     @rooms = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", params[:room_type_id],session[:hotel_id]) 
      session[:total_room] = cookies[:total_room].to_i
      session[:room_needed] = cookies[:room_needed].to_i

    @rooms.each do |room|
      if (room.from_date..room.to_date).cover?(session[:checkin].to_date) || (room.from_date..room.to_date).cover?(session[:checkout].to_date)
        if room.number < session[:room_needed]
          @available_flag = 1
          return redirect_to root_path
        end
      end
    end

    @statuses = RoomStatus.where("room_sub_type_id=? AND hotel_id=?", params[:room_type_id],session[:hotel_id])
    logger.info"^^^^^^^^^^^^#{@statuses.inspect}^^^^^^^^^^^^^^^^^^^^"
    @end_flag = @available_flag = (session[:checkout].to_date - session[:checkin].to_date).to_i + 1
    @statuses.each do |status|
      @flag = 0
      
    if (status.from_date..status.to_date).cover?(session[:checkin].to_date) || (status.from_date..status.to_date).cover?(session[:checkout].to_date)
        if status.status == true
          @status_flag = 1
          return redirect_to root_path
        else
          @flag += 1
        end
      end
      if (status.from_date..status.to_date).cover?(session[:checkin].to_date)
        @checkin_flag = 1
      end
      if (status.from_date..status.to_date).cover?(session[:checkout].to_date)
        @checkout_flag = 1
      end
      ((session[:checkout].to_date - session[:checkin].to_date).to_i + 1).times do |day|
        if (status.from_date..status.to_date).cover?(session[:checkin].to_date.advance(days: day))
          @end_flag -= 1
        end
      end
    end
    logger.info"((((((((#{@flag}((((((#{@end_flag}((((#{@checkin_flag}((((((((#{@checkout_flag}((((("
    if @end_flag > 0 || @checkin_flag == 0 || @checkout_flag == 0
      return redirect_to root_path
    end

    @availables = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", params[:room_type_id],session[:hotel_id])
    @availables.each do |available|
      ((session[:checkout].to_date - session[:checkin].to_date).to_i + 1).times do |day|
        if (available.from_date..available.to_date).cover?(session[:checkin].to_date.advance(days: day))
          if available.number > 0
            @available_flag -= 1
            logger.info"&&&&&&&&&&&&&&&&#{@available_flag}&&&&&&&&&&&&13131313&&&&&"
          end
        end
      end
    end
    logger.info"&&&&111&&&&&&&&&&&&#{@available_flag}&&&&&&&&&&&&&&&&&"
    if @available_flag > 0
      return redirect_to root_path
    end
      
    session[:hotel_id] = params[:hotel_id]
    session[:room_type_id] = params[:room_type_id]
    @rates = RoomRate.where("room_type_id=? AND hotel_id=?", params[:room_type_id], params[:hotel_id])
   numbers = params[:room_number].to_i
   logger.info"****************#{session[:nights]}******************"
   room = Room.find_by_hotel_id_and_room_sub_type_id(params[:hotel_id], params[:room_type_id])
   @additional_adult_fee = cookies[:additionaladult].to_i * room.additionaladultfee.to_i
    if session[:room_needed]
      @amount = (cookies[:rate].to_f * session[:room_needed].to_f) + @additional_adult_fee
    else
      @amount = cookies[:rate].to_f + @additional_adult_fee
    end
    #end
    session[:subtotal] = @amount
    session[:roomtype] = params[:room_type_id].to_i
    if current_traveler
      redirect_to book_hotel_path(current_traveler)
    end
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
    room = Room.find_by_hotel_id_and_room_sub_type_id(session[:hotel_id], session[:room_type_id])
    @additional_adult_fee = cookies[:additionaladult].to_i * room.additionaladultfee.to_i
    if session[:room_needed]
      @amount = (cookies[:rate].to_f * session[:room_needed].to_f) + @additional_adult_fee
    else
      @amount = cookies[:rate].to_f + @additional_adult_fee
    end
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
          render :action => "checkout" and return
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

    @number_nights = ((a.to_date - b.to_date).to_i)
    room_ids = []
    
   
    @Room = RoomRate.find_by_room_type_id(session[:room_type_id])
    numbers = session[:roomtype].to_i
    logger.info"^^^^^^^^^^#{session[:roomtype]}^^^^^^^^^^^^^^6"
    @find_room_type = RoomType.find_by_id(session[:roomtype])
    # @room_type = @find_room_type.room_type
    @rates = RoomRate.where("room_type_id=? AND hotel_id=?", params[:room_type_id], params[:hotel_id])
   numbers = params[:room_number].to_i
   logger.info"****************#{session[:nights]}******************"
    # if !session[:nights].nil?
    #   @amount = session[:rate] * session[:nights]
    # else

    #end
    
    room_ids.push(room.id)
    @room_amount = room.price.to_f
    session[:subtotal] = @amount

    @checkin = session[:checkin]
    @checkout = session[:checkout]
    @available_flag = 0
    @status_flag = 0
     numbers = session[:roomtype].to_i
        @room1 = Room.find_by_hotel_id_and_room_sub_type_id(session[:hotel_id], session[:room_type_id])
        @rooms = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", @room1.room_sub_type_id,session[:hotel_id])
        @rooms.each do |room|
          if (room.from_date..room.to_date).cover?(session[:checkin].to_date) || (room.from_date..room.to_date).cover?(session[:checkout].to_date)
            if room.number < session[:room_needed]
              @available_flag = 1
              return redirect_to root_path
            end
          end
        end
        @statuses = RoomStatus.where("room_sub_type_id=? AND hotel_id=?", @room1.room_sub_type_id,session[:hotel_id])
        @statuses.each do |status|
          if (status.from_date..status.to_date).cover?(session[:checkin].to_date) || (status.from_date..status.to_date).cover?(session[:checkout].to_date)
            if status.status == true
              @status_flag = 1
              return redirect_to root_path
            end
          end
        end

        #Bookings data saving
        numbers = session[:room_needed].to_i
        logger.info"(((#{@available_flag}((((((((((#{@status_flag}((((((("
        if @available_flag == 0 && @status_flag == 0
          numbers.times do |n|
             booking = Booking.new(hotel_id: @room1.hotel.id, room_id: @room1.id, from_date: from_date, to_date: to_date, 
                          adults: numbers, traveler_id: @traveler.id, night_number: @number_nights, price: @amount, guests: cookies[:guests])
          
            booking.save
          end
        end
        @get_bookings = Booking.where(traveler_id: @traveler.id, hotel_id: room.hotel.id).order("created_at DESC").limit(1)
        @get_bookings.each do |booking|
          @booking_number = booking.id
          @booking_created_on = booking.created_at.strftime("%d-%m-%Y %H:%M:%S")
        end

        @room_type = RoomSubType.find_by_id(session[:room_type_id].to_i)
        @get_room_type = @room_type.name
        @last_booked = Booking.where(traveler_id: @traveler.id, hotel_id: @hotel.id).order("created_at DESC").limit(1)
        @price = session[:price]["#{session[:roomtype]}"]
    if @available_flag == 0 && @status_flag == 0 && book(@traveler, @amount, @card_number, @ccv, @card_type, @hotel,@booking_number, @booking_created_on, @checkin, @checkout, session[:room_needed], @get_room_type, @room1, @last_booked, @price, @number_nights )
      ## Create booking record and availability record
       @rate = @room1.price.to_f
        @rooms.each do |room|
          unless room.from_date == from_date.to_date && room.to_date == to_date.to_date
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if (room.from_date..room.to_date).include?(from_date.to_date.advance(days: date))              
                create_sell(room.room_sub_type_id,session[:hotel_id],room.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(:days => date),room.number - session[:room_needed].to_i)
              end
            end
          else
            room.number = room.number - session[:room_needed]
            room.save
          end
        end
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
        @fax_email = FaxMailer.hotel_booking_mail(@traveler, @amount, @card_number, @ccv, @card_type, @hotel, @checkin, @checkout, session[:room_needed], @latest_booked, @room1,@rate,@card_expiry, request.protocol,request.host_with_port, @number_nights, @price).deliver
        if !@hotel.email.nil? &&  @hotel.email != ""
          @fax_email_to_hotel = FaxMailer.email_to_hotel(@traveler, @amount, @card_number, @ccv, @card_type, @hotel, @checkin, @checkout, room_ids, @latest_booked, @room1, @card_expiry, request.protocol,request.host_with_port, session[:room_needed], @number_nights, @price).deliver
        end
        cookies.delete :guests
        cookies.delete :additionaladult
    else
      flash[:errors] = ["Your booking failed!"]
      return redirect_to checkout_path
    end        
  end
  
  def subregion_options
    render partial: 'test'
  end

  def landing
    @contact = Contact.new
  end
  
  def create_contact
    @contact = Contact.new
    @contact.name = params[:contact][:name]
    @contact.phone_number = params[:contact][:phone_number]
    @contact.email = params[:contact][:email]
    respond_to do |format|
      if @contact.save
        ContactMailer.contact_email(@contact.email,@contact.phone_number,@contact.name).deliver
        flash[:success] = "Your Entry Has Been Submitted. Please Register Your Property!"
        format.html { redirect_to registerhotel_path}
        format.json { render json: @contact, status: :created, location: @contact }
      else
        flash[:errors] = "Please enter with correct data"
        format.html { redirect_to registerhotel_path }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private

  def book(traveler, amount, cardnumber,ccv, cardtype, hotel, booking_number, booking_created_on, checkin, checkout, room_ids, room_type, room, booking, price, nights)
    logger.info"@@@@@@@@@@#{traveler.inspect}@@@@@@#{amount}@@@@@@@@@@@@#{cardnumber}@@@@@@@@#{cardtype}@@@@@@#{checkin}@@@@@@#{checkout}@"
    @image = '<img src="http://23.253.149.108/e-mail-logo.jpg" width="316" height="52" alt=''>'
    #TODO make this work with the fax service
    @disclaimer = CGI::unescape("Disclaimer"+"\n"+"* A confirmation has been sent to the guest with all of the booking details"+"\n"+"* It is your duty , as the booking property, to safeguard this fax and the guests credit card info in a secure way that follows your company's security policies")
    @policy = CGI::unescape("Within 48 hours, unless specified by the individual hotel.")
    @booking_data = ""
    @night_data = ""
    @guest_data = ""
    #price = view_context.number_with_precision(price, precision: 2, separator: '.')
    File.open("#{Rails.root.to_s}/public/fax_content.html", 'wb') do|f|
      booking.each do |book|
        nights.times do |night|
          @booking_data += '<td style="height:40px; color:#000;border:1px solid #000; word-break: break-word;" width="100px">' + "#{book.from_date.advance(days: night).strftime("%m")}" +'/ '+"#{book.from_date.advance(days: night).strftime("%d")}"+'</td>'
        end 
      end 

      booking.each do |book|
        nights.times do |night|
          @night_data += '<td style="height:40px; color:#000;border:1px solid #000; word-break: break-word;">'+"#{view_context.number_with_precision((amount / nights), precision: 2, separator: '.')}"+'</td>'
        end
      end

      booking.each do |book|
        @guest_data += '<td style="font-weight: bold; width: 30%;">' + "#{book.guests}" + '</td>'
      end

      @country = Carmen::Country.coded(@traveler.country_id )
      @subregion = @country.subregions.coded(@traveler.state_id)
      @hotel_country = Carmen::Country.coded(@hotel.country_id )
      if !@hotel_country.blank? && @hotel_country.name == "Canada"
        @currency = "CAD"
      else
        @currency = "USD"
      end

     html = '<html>'\
      '<body>'\
        '<div style="margin: 60px">'\
        '<div style="float: left; width: 40%; font-weight: bold; font-size: 35px; text-align: center;">BestNights.com</div>'\
        '<div style="float: right; width: 34%">'\
          '<div style="font-size: 20px;font-weight: 500;"><span>Booking confirmation</span><br/><span style="font-weight: bold;">'+ "#{booking_number.to_s}" +'</span></div>'\
        '</div><div style="clear: both"></div>'\
        '<div style="margin-top: 10px;;">'\
          '<table cellspacing="0" width="100%" cellpadding="0" align="center" style="text-align: left; font-size:14px;">'\
            '<tbody>'\
              '<tr>'\
                '<td>Fax To:</td>'\
                '<td style="font-weight: bold;">' + "#{hotel.name.titleize}" + '</td>'\
                '<td>Date:</td>'\
                '<td style="font-weight: bold;">' + "#{booking_created_on.to_date.strftime("%A,%d %B %Y")}" + '</td>'\
              '</tr>'\
              '<tr>'\
                '<td>Fax:</td>'\
                '<td style="font-weight: bold;">' + "#{hotel.fax}" + '</td>'\
                '<td>Concerning:</td>'\
                '<td style="font-weight: bold;">Booking:' + "#{booking_number.to_s}" + '</td>'\
              '</tr>'\
            '</tbody>'\
          '</table>'\
        '</div>'\
        '<div style="margin-top: 15px;;">'\
          '<div>Dear '+ "#{hotel.name.titleize}" +',</div><br/>'\
          '<div>We have received the following information for your hotel  and are confirming via fax.</div><br/>'\
          '<div>'\
            'If you have any questions regarding this reservation, please feel free to contact us. Telephone English Support 1 800 494 BEST (2378), Email Customer: info@bestnights.com <br/>'\
          '</div><br/>'\
          '<div>Kindest Regards, Bestnights.com</div>'\
        '</div>'\
        '<div style="height:10px;"></div>'\
        '<table cellspacing="0" width="100%" cellpadding="0" align="center" style="text-align: left; font-size:14px;">'\
          '<tbody>'\
            '<tr>'\
              '<td style="width: 15%;">Arrival:</td>'\
              '<td style="font-weight: bold; width: 30%;">' + "#{checkin.to_date.strftime("%A,%d %B %Y")}" +'</td>'\
              '<td style="width:20%;">Number of Rooms:</td>'\
              '<td style="font-weight: bold; width: 30%;">' + "#{room_ids}" + '</td>'\
            '</tr>'\
            '<tr>'\
              '<td style="width: 15%;">Departure:</td>'\
              '<td style="font-weight: bold; width: 30%;">' + "#{checkout.to_date.strftime("%A,%d %B %Y")}" + '</td>'\
              '<td style="width:20%;">Number of Guests:</td>'\
              + "#{@guest_data}" +
            '</tr>'\
          '</tbody>'\
        '</table>'\
        '<div style="margin-top: 10px;;">'\
          '<div style="float: left;width: 45%;font-weight: bold; font-size: 14px;">'+ "#{room_type.titleize}" +' for guest ' + "#{traveler.name.titleize}" + '</div><br/>'\
        '</div>'\
        '<div style="margin-top: 10px;;">'\
        '<table cellspacing="0" cellpadding="0" style="text-align: center; font-size:12px;">'\
          '<tr style="color:#000;">'\
            '<td style="border:1px solid #000; word-break: break-word;">Date</td>'\
            + "#{@booking_data}" +
          '</tr>'\
          '<tr style="color:#000;">'\
            '<td style="border:1px solid #000; word-break: break-word;">Rate (' + "#{@currency}" + ')</td>'\
            + "#{@night_data}" +
          '</tr>'\
        '</table>'\
          '</div>'\
        '<div style="height:10px;"></div>'\
        '<table cellspacing="0" width="100%" cellpadding="0" align="center" style="text-align: left; font-size:14px;">'\
          '<tbody>'\
            '<tr>'\
              '<td style="font-weight: bold; font-size: 17px;" colspan="4">Total Price for this reservation: '"#{@currency}" + "#{amount}" + ' (taxes not included) </td>'\
            '</tr>'\
            '<tr style="height:95px;"><td></td></tr>'\
            '<tr>'\
              '<td style="width:20%;">Credit Card:</td>'\
              '<td style="font-weight: bold; width:20%">' + "#{traveler.credit_card_type.titleize}" + '</td>'\
              '<td style="width:15%;">Expiry Date:</td>'\
              '<td style="font-weight: bold; width:20%;">' + "#{traveler.credit_card_expiry_date.strftime("%m/%y")}" + '</td>'\
            '</tr>'\
            '<tr>'\
              '<td style="width:20%;">Card Number:</td>'\
              '<td style="font-weight: bold; width:20%;">' + "#{traveler.credit_card_number}" + '</td>'\
              '<td></td>'\
              '<td></td>'\
            '</tr>'\
          '</tbody>'\
        '</table>'\
        '<div style="clear: both;"></div>'\
        '<div style="margin-top: 10px;;">'\
          '<div>It&#039;s Your Obligation to Safeguard this fax and keep this guests credit card information secure in accordance with your internal security procedures.</div>'\
        '</div>'\
        '<div style="margin-top: 10px;">'\
          '<table cellspacing="0" width="100%" cellpadding="0" align="center" style="text-align: left; font-size:14px;">'\
            '<tbody>'\
              '<tr>'\
                '<td>Booked By:</td>'\
                '<td style="font-weight: bold;">' + "#{traveler.name.titleize}" + '</td>'\
                '<td>Zip Code:</td>'\
                '<td style="font-weight: bold;">' + "#{traveler.zip.titleize}" + '</td>'\
              '</tr>'\
              '<tr>'\
                '<td>Address:</td>'\
                '<td style="font-weight: bold;">' + "#{traveler.address1.titleize}" + '</td>'\
                '<td>State:</td>'\
                '<td style="font-weight: bold;">' + "#{@subregion.name}" + '</td>'\
              '</tr>'\
              '<tr>'\
                '<td>City:</td>'\
                '<td style="font-weight: bold;">' + "#{traveler.city.titleize}" + '</td>'\
                '<td>Country:</td>'\
                '<td style="font-weight: bold;">' + "#{@country.name}" + '</td>'\
              '</tr>'\
              '<tr>'\
                '<td>Telephone:</td>'\
                '<td style="font-weight: bold;">' + "#{traveler.phone_number}" + '</td>'\
                '<td></td>'\
                '<td></td>'\
              '</tr>'\
            '</tbody>'\
          '</table>'\
        '</div>'\
        '<div style="clear: both;"></div>'\
        '<div style="margin-top: 25px;">'\
          '<ul>'\
            '<li>IMPORTANT: '+ "#{@disclaimer}" +'</li>'\
            '<li>We have sent a confirmation to the guest with the booking details, hotel address with contact details, cancellation and checkin/checkout times.</li>'\
            '<li>Please keep your availability current on www.bestnights.com</li>'
          '</ul>'\
        '</div>'\
      '</div>'\
      '</body>'\
      '</html>'
      f.write(html) 
      end
    results = []
    chars = 0
    data = ""
    File.open("#{Rails.root.to_s}/public/fax_content.html", 'r').each { |line| results << line }
      results.each do |line|
      chars += line.length
      data += line
    end
  
   @fax_result = SOAP::WSDLDriverFactory.new("https://ws-sl.fax.tc/Outbound.asmx?WSDL").create_rpc_driver.SendCharFax("Username" => "bestnights","Password" => "2014bestnights","FileType" => "HTML","FaxNumber"=> "18444942378","Data" => data)
    logger.info"@@@@@@@@@@@@@@@@@@@@@@@#{@fax_result.inspect}@@@@@@@@@@@@@@@@@@@@@@@@"
   # File.delete("#{Rails.root.to_s}/public/"+traveler.id.to_s+".txt")
   unless @fax_result["SendCharFaxResult"].include? "-"
    TravelerPayment.create(amount: amount, traveler_id: traveler.id)
   else
    flash[:notice] = "Hotel not booked due wrong params"
    redirect_to root_path
   end
  end
end
