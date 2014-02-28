class AddAttachmentPictureToRoomPhotos < ActiveRecord::Migration
  def self.up
    change_table :room_photos do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :room_photos, :picture
  end
end
