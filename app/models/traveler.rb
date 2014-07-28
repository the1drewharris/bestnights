class Traveler < ActiveRecord::Base
  
  devise :database_authenticatable, :trackable, :registerable,:recoverable
         
  attr_accessible :firstname, :lastname, :address1, :address2, :city, :zip, :email,
                  :phone_number, :state_id, :country_id, :password, :password_confirmation, :credit_card_type,
                  :credit_card_number, :ccv, :credit_card_expiry_date
  
  validates :firstname, :lastname, :address1, :city, :state_id, :country_id, :zip, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, on: :create
  validates :password, length: {minimum: 6}, on: :create
  
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
