class FaqCategory < ActiveRecord::Base
  attr_accessible :name
  has_many :faqs, dependent: :destroy
  validates :name, presence: true
end
