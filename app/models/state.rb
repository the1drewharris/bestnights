class State < ActiveRecord::Base
  attr_accessible :state_province, :abbreviation, :country_id
  
  belongs_to :country
  
  has_many :hotels
  has_many :travelers  
  has_many :venues
  has_many :users
end
