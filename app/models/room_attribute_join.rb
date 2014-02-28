class RoomAttributeJoin < ActiveRecord::Base
  attr_accessible :room_id, :room_attribute_id
  
  validates :room_id, :room_attribute_id, presence: true
  
  belongs_to :room
  belongs_to :room_attribute
end
