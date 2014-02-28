class Availability < ActiveRecord::Base
  attr_accessible :this_date, :count, :starting_inventory, :room_id
  
  belongs_to :room
  
  validates :room_id, presence: true
  validates :this_date, presence: true
  validates :count, :starting_inventory, presence: true, numericality: { only_integer: true, :greater_than_or_equal_to => 0 }
  validates :count, numericality: { :less_than_or_equal_to => :starting_inventory }
end
