class Hotel < ActiveRecord::Base
  attr_accessible :name, :description, :address1, :city, :state_id, :zip, :user_id, :country_id, :star, :status, 
                  :comission_rate, :card_id, :email_or_fax, :email, :fax, :tax1_label, :tax1, :tax2_label, :tax2, 
                  :tax3_label, :tax3, :tax4_label, :tax4, :policy, :phone
  
  validates_presence_of :name, :description, :address1, :city, :user_id, :country_id, :status,
                        :tax1_label, :tax2_label, :tax3_label, :tax4_label, :policy, :on => :create
  
  validates :email, presence: true,
    if: Proc.new { |a| a.email_or_fax == "email" }
  validates :fax, presence: true,
    if: Proc.new { |a| a.email_or_fax == "fax" }
  validates :tax1, :tax2, :tax3, :tax4, :numericality => true
  validates :zip, :numericality => true
  
  after_initialize :init
  
  belongs_to :state
  belongs_to :country
  belongs_to :user
  belongs_to :card
  has_many :rooms, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :hotel_photos, dependent: :destroy
  has_many :room_photos, dependent: :destroy
  has_many :promotions, dependent: :destroy
  
  has_many :hotel_attribute_joins, dependent: :destroy
  has_many :hotel_attributes, through: :hotel_attribute_joins
  has_many :users, dependent: :destroy # front desks, not admin and manager
  has_many :contact_persons, dependent: :destroy
  has_one  :commission_rate
  has_many :room_statuses
  
  scope :activated, -> { where(status: "active") }
  scope :top5, -> { where(status: "active").order("star DESC").limit(5) }
  
  def self.latest_joined_hotels
    find :all, :order => "created_at DESC"
  end
  
  def self.search(search)
    if search
      find(:all, :conditions => ['status = ? and (name LIKE ? or city LIKE ?)', "active", "%#{search}%", "%#{search}%"])
    else
      find(:all)
    end
  end
  
  def lowest_price
    unless rooms.empty?
      rooms.order("price ASC").first.price.to_f
    else
      0.0    
    end    
  end
  
  def room_attributes
    room_attributes = []
    
    rooms.each do |room|
      room_attributes = room_attributes + room.room_attributes
    end
    
    room_attributes.group_by { |d| d[:attr]}
  end 
  
  def available?(checkin, checkout, room_numbers, bed_numbers)
    
    available_rooms = [] # rooms available during the period
    
    rooms.each do |room|
      if room.available?(checkin, checkout)
        available_rooms << room
      end        
    end
    
    if available_rooms.count >= room_numbers.to_i
      bed_numbers_arr = []
      available_rooms.each do |room|
        bed_numbers_arr << room.bed_numbers
      end      
      
      bed_numbers_arr = bed_numbers_arr.uniq
      
      if !bed_numbers.empty? and (bed_numbers & bed_numbers_arr) == bed_numbers
        return true
      end        
    end
    return false
  end
  
  
  private 
  
  def init
    self.tax1  ||= 0.0
    self.tax2  ||= 0.0
    self.tax3  ||= 0.0
    self.tax4  ||= 0.0
    self.comission_rate  ||= 14.0
    self.status ||= "non-active"
  end
  
  
end
