class RoomSubType < ActiveRecord::Base
  attr_accessible :name, :room_type_id
  belongs_to :room_type
  has_many :rooms
  validates :room_type_id, presence: true, on: :create
end
