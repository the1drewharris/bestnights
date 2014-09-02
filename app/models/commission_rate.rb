class CommissionRate < ActiveRecord::Base
  attr_accessible :amount
  belongs_to 	  :hotel
  validates :amount, presence: true, inclusion: { in: 0..10000 }
  

  def self.amount
  	return self.first.amount
  end
end
