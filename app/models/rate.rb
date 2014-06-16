class Rate < ActiveRecord::Base
  attr_accessible :category, :hotel_id, :from_date, :to_date, :price
end
