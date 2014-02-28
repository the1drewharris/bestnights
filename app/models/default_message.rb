class DefaultMessage < ActiveRecord::Base
  attr_accessible :message
  
  validates :message, presence: true
  
end
