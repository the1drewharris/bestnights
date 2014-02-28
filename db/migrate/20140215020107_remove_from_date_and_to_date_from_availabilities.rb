class RemoveFromDateAndToDateFromAvailabilities < ActiveRecord::Migration
  def up
    remove_column :availabilities, :from_date
    remove_column :availabilities, :to_date
  end

  def down
    add_column :availabilities, :to_date, :datetime
    add_column :availabilities, :from_date, :datetime
  end
end
