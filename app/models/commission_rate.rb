class CommissionRate < ActiveRecord::Base
  attr_accessible :amount
  belongs_to 	  :hotel
  validates :amount, presence: true

  def self.amount
  	return self.first.amount
  end
end
