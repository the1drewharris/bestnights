class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  
  validates_uniqueness_of :email, message: 'That email already exists'
  validates_confirmation_of :password
  
  def admin?
    self.role == 1
  end
  
  def manager?
    self.role == 2
  end
end
