class RoomSubType < ActiveRecord::Base
  attr_accessible :name, :room_type_id, :hotel_id, :is_active
  belongs_to :room_type
  belongs_to :hotel
  has_many :rooms
  validates :room_type_id, presence: true, on: :create
  validates :hotel_id, presence: true, on: :create
  validates :name, presence: true, on: :create
end