class CommissionRate < ActiveRecord::Base
  attr_accessible :amount
  belongs_to 	  	:hotel
  validates :amount, presence: true,  numericality: { :greater_than_or_equal_to => 0 }

  def self.amount
  	return self.first.amount
  end
end
