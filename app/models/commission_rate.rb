class CommissionRate < ActiveRecord::Base
  attr_accessible :amount

  def self.amount
  	return self.first.amount
  end
end
