class RoomType < ActiveRecord::Base
  attr_accessible :hotel_id, :type
  belongs_to :hotel
  has_many :room_prices
  has_many :availabilities
  has_many :bookings
end
