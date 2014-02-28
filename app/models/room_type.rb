class RoomType < ActiveRecord::Base
  attr_accessible :room_type, :status
  
  validates :room_type, presence: true, uniqueness: { case_sensitive: false }
  
  after_initialize :init
  
  has_many :bookings
  has_many :rooms
  
  scope :activated, -> { where(status: "active") }
  
  def init
    self.status ||= "non-active"
  end
end
