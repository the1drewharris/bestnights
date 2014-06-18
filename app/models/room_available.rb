class RoomAvailable < ActiveRecord::Base
  attr_accessible :days, :from_date, :number, :room_id, :room_type_id, :status, :to_date
end
