class Traveler < ActiveRecord::Base
  
  devise :database_authenticatable, :trackable
         
  attr_accessible :firstname, :lastname, :address1, :address2, :city, :zip, :email,
                  :phone_number, :state_id, :country_id, :password, :password_confirmation
  
  validates :firstname, :lastname, :address1, :city, :state_id, :country_id, :zip, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password, confirmation: true
  validates :password, length: {minimum: 6}
  
  belongs_to :country
  belongs_to :state
  
  has_many :bookings, dependent: :destroy
  has_many :traveler_payments, dependent: :destroy
  
  def name
    "#{firstname} #{lastname}"
  end
  
  def self.search(search)
    if search
      find(:all, :conditions => ['firstname LIKE ? Or lastname LIKE ?', "%#{search}%", "%#{search}%"])
    else
      find(:all)
    end
  end
end
