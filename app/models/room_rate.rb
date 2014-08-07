class RoomRate < ActiveRecord::Base
  attr_accessible :room_id, :room_type_id, :from_date, :to_date, :price
  belongs_to :room
  belongs_to :room_type
end
