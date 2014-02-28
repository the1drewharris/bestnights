class RoomAttribute < ActiveRecord::Base
  attr_accessible :attr
  
  validates :attr, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :room_attribute_joins
  has_many :rooms, through: :room_attribute_joins
end
