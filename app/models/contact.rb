class Contact < ActiveRecord::Base
  attr_accessible :email, :name, :phone_number, :message
  validates :email, :name, presence: true
end
