class Country < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :travelers
  has_many :states
end
