class Room < ActiveRecord::Base
  attr_accessible :hotel_id, :room_type_id, :name, :description, :price, :additionaladultfee, :original_price, :starting_inventory, :bed_numbers, :max_people, :max_children, :room_size, :room_unit, :lunch, :dinner, :all_inclusive
  
  validates :hotel_id, :room_type_id, presence: true
  validates :starting_inventory, :bed_numbers, presence: true, numericality: { only_integer: true }
  
  after_initialize :init
  before_save :set_value_before_save
  
  belongs_to :hotel
  belongs_to :room_type
  
  has_many :availabilities, dependent: :destroy
  has_many :room_photos, dependent: :destroy
  has_many :room_attribute_joins, dependent: :destroy
  has_many :room_attributes, through: :room_attribute_joins
  has_many :room_rate_details
  has_many :room_rates
  
  def self.latest_rooms
    find :all, :order => "updated_at DESC"
  end
  
  def available?(from_date, to_date)
    sold_outed = availabilities.where("this_date > ? and this_date < ? and count = ?", from_date, to_date, 0)
    if sold_outed.empty?
      true
    else
      false
    end
  end
  
  def available_max(from_date, to_date)
    booked = availabilities.where("this_date > ? and this_date < ? and count <> ?", from_date, to_date, 0).order("count")
    if booked.empty?
      starting_inventory
    else
      booked.first.count
    end
  end
  
  def self.search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
  
  private
  
  def init
    self.starting_inventory ||= 1
    self.price  ||= 0.0
    self.original_price  ||= 0.0
    self.additionaladultfee  ||= 0.0
    self.bed_numbers  ||= 1
  end
  
  def set_value_before_save
    self.name = self.room_type.room_type if self.name.empty?
  end
end
