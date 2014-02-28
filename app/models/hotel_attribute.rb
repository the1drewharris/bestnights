class HotelAttribute < ActiveRecord::Base
  attr_accessible :attr, :hotel_id
  
  validates :attr, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :hotel_attribute_joins
  has_many :hotels, through: :hotel_attribute_joins
end
