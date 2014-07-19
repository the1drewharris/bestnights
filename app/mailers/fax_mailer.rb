class FaxMailer < ActionMailer::Base
  default from: "info@bestnights.com"

  def hotel_booking_mail(traveler, amount, cardnumber, ccv, expiration, cardtype, hotel, checkin, checkout, room_ids, latest_booked, room)
  	@traveler = traveler
  	@amount = amount
  	@cardnumber = cardnumber
    @ccv = ccv
  	@expiration = expiration
  	@cardtype = cardtype
  	@hotel = hotel
  	@checkin = checkin
  	@checkout = checkout
  	@room_numbers = room_ids
    @booking = latest_booked
    @room = room
  	subject = "Bestnights Booking Confirmation"
    mail(:subject => subject, :to => @traveler.email)
  end

  def email_to_hotel(traveler, amount, cardnumber, ccv, expiration, cardtype, hotel, checkin, checkout, room_ids, latest_booked, room)
    @traveler = traveler
    @amount = amount
    @cardnumber = cardnumber
    @ccv = ccv
    @expiration = expiration
    @cardtype = cardtype
    @hotel = hotel
    @checkin = checkin
    @checkout = checkout
    @room_numbers = room_ids
    @booking = latest_booked
    @room = room
    subject = "Booking Hotel"
    mail(:subject => subject, :to => @hotel.email)
  end
end
