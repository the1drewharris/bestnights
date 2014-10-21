class Card < ActiveRecord::Base
  attr_accessible :card_type, :card_number, :ccid, :expiration
  has_many :hotels
  
  validates :card_type, presence: true

end
