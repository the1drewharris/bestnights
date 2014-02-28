class HotelAttributeJoin < ActiveRecord::Base
  attr_accessible :hotel_id, :hotel_attribute_id
  
  validates :hotel_attribute_id, :hotel_id, presence: true
  belongs_to :hotel
  belongs_to :hotel_attribute
  
  scope :topfeatures6,
    select("hotel_attribute_id, count(hotel_attribute_id) AS attribute_counts").
    group("hotel_attribute_id").
    order("attribute_counts DESC").
    limit(6)
end
