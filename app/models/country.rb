class Country < ActiveRecord::Base
  attr_accessible :country, :abbreviation
  has_many :travelers
  has_many :states
  has_many :users
end
