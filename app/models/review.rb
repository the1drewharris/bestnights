class Review < ActiveRecord::Base
  attr_accessible :hotel_id, :reviewer_id, :review, :status, :stars
  
  belongs_to :hotel
  
  validates :hotel_id, :reviewer_id, :review, presence: true
  validates :stars, presence: true, :numericality => true
end
