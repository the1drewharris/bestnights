class Promotion < ActiveRecord::Base
  attr_accessible :coupon_code, :start_date, :expiry_date, :transaction_item, :percent, :discount, :times_allowed, :hotel_id
  
  validates :coupon_code, :start_date, :expiry_date, :hotel_id, presence: true
  validates :times_allowed, presence: true, numericality: { only_integer: true }
  
  belongs_to :hotel
  
  after_initialize :init
  
  def init
    self.times_allowed ||= 1
  end
end
