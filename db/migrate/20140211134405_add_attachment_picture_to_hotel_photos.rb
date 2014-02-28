class AddAttachmentPictureToHotelPhotos < ActiveRecord::Migration
  def self.up
    change_table :hotel_photos do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :hotel_photos, :picture
  end
end
