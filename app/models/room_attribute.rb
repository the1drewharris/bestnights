class RoomAttribute < ActiveRecord::Base
  attr_accessible :attr
  
  validates :attr, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :room_attribute_joins, dependent: :destroy
  has_many :rooms, through: :room_attribute_joins
  
  def self.search(search)
    if search
      find(:all, :conditions => ['attr LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
  
end
