class FaxMailer < ActionMailer::Base
  default from: "info@bestnights.com"

  def hotel_booking_mail(traveler, amount, cardnumber, expiration, cardtype, hotel, checkin, checkout, room_ids)
  	@traveler = traveler
  	@amount = amount
  	@cardnumber = cardnumber
  	@expiration = expiration
  	@cardtype = cardtype
  	@hotel = hotel
  	@checkin = checkin
  	@checkout = checkout
  	@room_numbers = room_ids
  	subject = "Booking Hotel"
    mail(:subject => subject, :to => @hotel.email)
  end
end
