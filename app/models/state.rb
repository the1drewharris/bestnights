class State < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :hotels
  has_many :travelers
  belongs_to :country
  has_many :venues
end
