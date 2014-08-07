class RoomType < ActiveRecord::Base
  attr_accessible :room_type, :status, :base_price
  
  validates :room_type, presence: true, uniqueness: { case_sensitive: false }
  validates :base_price, presence: true
  
  after_initialize :init
  
  has_many :bookings
  has_many :rooms
  has_many :room_types
  has_many :room_availables
  
  scope :activated, -> { where(status: "active") }
  
  def init
    self.status ||= "non-active"
  end
  
  def self.search(search)
    if search
      find(:all, :conditions => ['room_type LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
end
