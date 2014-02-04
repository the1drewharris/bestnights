class Agreement < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :hotel  
end
