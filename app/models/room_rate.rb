class RoomRate < ActiveRecord::Base
  attr_accessible :rate_friday, :rate_monday, :rate_saturday, :rate_sunday, :rate_thursday, :rate_tuesday, :rate_wednesday, :room_id, :room_type_id
  belongs_to :room
end
