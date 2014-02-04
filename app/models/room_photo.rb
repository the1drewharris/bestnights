class RoomPhoto < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :hotel
end
