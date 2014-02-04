class Availability < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :room_type
end
