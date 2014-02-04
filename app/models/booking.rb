class Booking < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :hotel
  belongs_to :room_type
end
