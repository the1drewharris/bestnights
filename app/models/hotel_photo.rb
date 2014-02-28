class HotelPhoto < ActiveRecord::Base
  attr_accessible :picture, :hotel_id
  
  validates :picture_file_name, :picture, :hotel_id, presence: true
  
  belongs_to :hotel
  
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb1 => "97x74>", :thumb2 => "72x72>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
end
