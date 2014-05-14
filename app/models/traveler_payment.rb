class TravelerPayment < ActiveRecord::Base
  attr_accessible :transactionid, :amount, :traveler_id
  
  # validates :transactionid, presence: true, uniqueness: true
  validates :traveler_id, presence: true
  validates :amount, numericality: true
  
  belongs_to :traveler
  
end
