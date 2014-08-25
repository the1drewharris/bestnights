class Country < ActiveRecord::Base
  attr_accessible :country, :abbreviation
  has_many :travelers
  has_many :states, dependent: :destroy
  has_many :users
  has_many :hotels
end
