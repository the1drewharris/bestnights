class RoomRateDetail < ActiveRecord::Base
  attr_accessible :day, :status, :rate_per_night,:booked,:canceled, :policy_group,:month,:year,:day, :room_id
  belongs_to :room        
end
