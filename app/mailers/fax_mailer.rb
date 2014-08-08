class FaxMailer < ActionMailer::Base
  default from: "info@bestnights.com"

  def hotel_booking_mail(traveler, amount, cardnumber, ccv, cardtype, hotel, checkin, checkout, numbers, latest_booked, room, rate, credit_card_expiry_date, protocol,host)
  	@traveler = traveler
  	@amount = amount
  	@cardnumber = cardnumber
    @ccv = ccv
  	@cardtype = cardtype
  	@hotel = hotel
  	@checkin = checkin
  	@checkout = checkout
  	@room_numbers = numbers
    @booking = latest_booked
    @room = room
    @rate = rate
    @protocol = protocol
    @host = host
    @expiry_date = credit_card_expiry_date
  	subject = "Bestnights Booking Confirmation"
    mail(:subject => subject, :to => @traveler.email)
  end
  
  def email_to_hotel(traveler, amount, cardnumber, ccv, cardtype, hotel, checkin, checkout, room_ids, latest_booked, room, credit_card_expiry_date, protocol,host, numbers)
    @traveler = traveler
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
end
