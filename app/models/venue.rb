class Venue < ActiveRecord::Base
  attr_accessible :state_id, :name, :description, :address1, :address2, :city, :zip, :state_id
  
  validates :name, :address1, :city, :state_id, :zip, presence: true
  
  belongs_to :state
end
