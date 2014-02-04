class Hotel < ActiveRecord::Base
  attr_accessible :name, :description, :address1, :city, :zip
  belongs_to :state
  has_many :room
  has_many :room_types
  has_many :room_prices
  has_many :reviews
  has_many :bookings
  has_many :aggreements
  has_many :hotel_photos
  has_many :room_photos
end
