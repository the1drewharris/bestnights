class RoomStatus < ActiveRecord::Base
  attr_accessible :from_date, :room_type_id, :status, :to_date, :hotel_id
  belongs_to :hotel
  belongs_to :room_type
end
