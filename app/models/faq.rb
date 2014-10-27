class Faq < ActiveRecord::Base
  attr_accessible :answer, :question, :category_id
  belongs_to :faq_category
end
