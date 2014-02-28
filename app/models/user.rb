class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, 
                  :firstname, :lastname, :address1, :city, :state_id, :country_id, :zip, :status, :hotel_id
  # attr_accessible :title, :body
  
  validates_uniqueness_of :email, message: 'That email already exists'
  validates_confirmation_of :password
  validates :role, :firstname, :lastname, :address1, :city, :state_id, :country_id, :status, presence: true  
  # validates :terms_of_service, acceptance: true
  
  after_initialize :init
  
  belongs_to :country
  belongs_to :state
  has_many :hotels
  belongs_to :hotel # must belong to the hotel when only front desk
  
  scope :admins, -> { where(role: "admin") }
  scope :managers, -> { where(role: "manager") }
  
  ROLE = ["admin", "manager", "front desk"]
  
  def init
    if ["manager", "front desk"].include?(self.role)
      self.status ||= "pending"
    else
      self.status ||= "active"
    end
     
  end
  
  def name
    "#{firstname} #{lastname}"
  end
  
  def admin?
    self.role == "admin"
  end
  
  def manager?
    self.role == "manager"
  end
  
  def front_desk?
    self.role == "front desk"
  end

  def traveler?
    self.role == "traveler"
  end
  
  def new_signup?
    self.sign_in_count <= 1
  end
  
  def activated?
    self.status == "active"
  end
    
  def activated_hotels
    Hotel.where(user_id: id, status: "active")
  end
  
  def hotel_attributes
    hotel_attributes = []
    hotels.each do |hotel|
      hotel.hotel_attributes.each do |ha|
        hotel_attributes << ha
      end
    end
    return hotel_attributes
  end
  
  def promotions
    promotions = []
    hotels.each do |hotel|
      hotel.promotions.each do |ha|
        promotions << ha
      end
    end
    return promotions
  end
  
  def rooms
    rooms = []
    hotels.each do |hotel|
      hotel.rooms.each do |room|
        rooms << room
      end
    end
    return rooms
  end
  
  def availabilities
    availabilities = []
    rooms.each do |room|
      room.availabilities.each do |availability|
        availabilities << availability
      end
    end
    return availabilities
  end   
end
