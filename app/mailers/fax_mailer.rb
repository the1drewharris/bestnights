class FaxMailer < ActionMailer::Base
  default from: "info@bestnights.com"

  def hotel_booking_mail(traveler, amount, cardnumber, ccv, cardtype, hotel, checkin, checkout, room_ids, latest_booked, room)
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
  	subject = "Bestnights Booking Confirmation"
    mail(:subject => subject, :to => @traveler.email)
  end

  def email_to_hotel(traveler, amount, cardnumber, ccv, cardtype, hotel, checkin, checkout, room_ids, latest_booked, room)
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
