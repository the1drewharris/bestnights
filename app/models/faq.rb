class Faq < ActiveRecord::Base
  attr_accessible :answer, :question, :category_id
  belongs_to :faq_category
  validates :question, presence: true
  validates :answer, presence: true
end
