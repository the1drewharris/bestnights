class RoomPhoto < ActiveRecord::Base
  attr_accessible :picture, :room_id, :hotel_id, :room_sub_type_id
  
  validates :picture_file_name, :picture, :room_id, :hotel_id, presence: true
  
  belongs_to :hotel
  belongs_to :room
  
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
  
end
