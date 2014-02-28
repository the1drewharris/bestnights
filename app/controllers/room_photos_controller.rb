class RoomPhotosController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    room = Room.find(params[:room_id])
    hotel = room.hotel
    @room_photo = RoomPhoto.new(picture: params[:picture], room_id: room.id, hotel_id: hotel.id)
    
    respond_to do |format|
      if @room_photo.save
        format.json { render json: @room_photo, status: 200 }
      else
        format.json { render json: @room_photo.errors, status: 500 }
      end
    end
  end
  
  def destroy
    @room_photo = RoomPhoto.find(params[:id])
    
    @room_photo.destroy unless params[:status] == "error"  
    
    respond_to do |format|
      format.json { render json: 'success', status: 200 }
    end    
  end
  
end
