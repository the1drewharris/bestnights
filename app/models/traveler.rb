class Traveler < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :address1, :address2, :city, :zip, :email, :phone_number
  belongs_to :country
  belongs_to :state
end
