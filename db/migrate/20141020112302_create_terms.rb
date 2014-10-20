class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
    	t.text	:content
      t.timestamps
    end
  end
end
