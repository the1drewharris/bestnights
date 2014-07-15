class ContactPerson < ActiveRecord::Base
  attr_accessible :title, :name, :designation, :gender, :email
  attr_accessible :phone_number, :mobile_number, :address, :postal_code, :city, :country 
  belongs_to :hotel
  belongs_to :position
end
