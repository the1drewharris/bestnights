class Booking < ActiveRecord::Base
  attr_accessible :hotel_id, :room_id, :price, :from_date, :to_date, :adults, :children, :message, :traveler_id, :night_number
  belongs_to :hotel
  belongs_to :room_type
  belongs_to :room
  belongs_to :traveler
  
  validates :hotel_id, :room_id, :from_date, :to_date, presence: true
  validates :price, presence: true, numericality: true
  validates :adults, :children, numericality: { only_integer: true }
  
  #after_initialize :init
  #before_save :calculate_price
  
  # def calculate_price
  #   room = Room.find(room_id)
  #   hotel = Hotel.find(hotel_id)
  #   self.price = room.price.to_f * adults
  # end
  
  # def init
  #   self.adults ||= 1
  #   self.children ||= 0
  #   self.price ||= 0.0
  # end
end
