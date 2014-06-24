class RoomRateDetail < ActiveRecord::Base
  attr_accessible :day, :status, :rate_per_night,:booked,:canceled, :policy_group,:month,:year,:room_id
  belongs_to :room  
  validates :status, presence: true
  validates :rate_per_night, presence: true
  validates :policy_group, presence: true
  validates :month, presence: true
  validates :year, presence: true
  validates :day, presence: true    
end
