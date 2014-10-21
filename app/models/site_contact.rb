class SiteContact < ActiveRecord::Base
  attr_accessible :phone_number, :fax, :email, :address
end
