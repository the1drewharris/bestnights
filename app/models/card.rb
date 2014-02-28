class Card < ActiveRecord::Base
  attr_accessible :card_type, :card_number, :ccid, :expiration
  has_many :hotels
  
  validates :card_type, presence: true
  validates :card_number, numericality: true, uniqueness: true
  validates :ccid, presence: true, numericality: true
  validates :expiration, presence: true, numericality: true
end
