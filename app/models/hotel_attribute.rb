class HotelAttribute < ActiveRecord::Base
  attr_accessible :attr, :hotel_id
  
  validates :attr, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :hotel_attribute_joins, dependent: :destroy
  has_many :hotels, through: :hotel_attribute_joins
  
  def self.search(search)
    if search
      find(:all, :conditions => ['attr LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
  
end
