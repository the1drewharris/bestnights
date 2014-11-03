class FaxMailer < ActionMailer::Base
  default from: "info@bestnights.com"

  def hotel_booking_mail(traveler, amount, cardnumber, ccv, cardtype, hotel, checkin, checkout, numbers, latest_booked, room, rate, credit_card_expiry_date, protocol,host, number_nights, price, room_sub_type)
  	@traveler = traveler
    @hotel = hotel
  	@amount = amount
  	@cardnumber = cardnumber
    @ccv = ccv
  	@cardtype = cardtype  	
  	@checkin = checkin
  	@checkout = checkout
  	@room_numbers = numbers
    @booking = latest_booked
    @room = room
    @rate = rate
    @protocol = protocol
    @host = host
    @expiry_date = credit_card_expiry_date
    @nights = number_nights
    @price = @amount
    @room_sub_type = room_sub_type
  	subject = "Bestnights Booking Confirmation"
    mail(:subject => subject, :to => @traveler.email)
  end
  
  def email_to_hotel(traveler, amount, cardnumber, ccv, cardtype, hotel, checkin, checkout, room_ids, latest_booked, room, credit_card_expiry_date, protocol,host, numbers, number_nights, price, room_sub_type)
    @traveler = traveler
    @country = Carmen::Country.coded(@traveler.country_id )
    @subregion = @country.subregions.coded(@traveler.state_id)
    @amount = amount
    @cardnumber = cardnumber
    @ccv = ccv
    @cardtype = cardtype
    @hotel = hotel
    @checkin = checkin
    @checkout = checkout
    @room_numbers = room_ids
    @booking = latest_booked
    @room = room
    @protocol = protocol
    @host = host
    @expiry_date = credit_card_expiry_date
    @nights = number_nights
    @price = price
    @room_sub_type = room_sub_type
    subject = "Booking Hotel"
    mail(:subject => subject, :to => @hotel.email)
  end

  def hotel_cancel_mail(traveler,hotel,booking)
    @traveler = traveler
    @hotel = hotel
    @booking = booking
    subject = "Bestnights Booking Cancelation"
    mail(:subject => subject, :to => [@hotel.email, "info@bestnights.com"])
  end

  def cron_mailer(bookings, hotel)
    @bookings = bookings
    @hotel = hotel
    subject = "Monthly Booking Status"
    mail(:subject => subject, :to => ["ujjal.bhattacharya@indusnet.co.in"])
    puts "Hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii"
  end
end
