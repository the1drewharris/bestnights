class ChangeQuestionTypeToText < ActiveRecord::Migration
  def up
  	change_column :faqs, :question, :text
  end

  def down
  	change_column :faqs, :question, :string
  end
end
