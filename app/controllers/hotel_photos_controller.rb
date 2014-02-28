class HotelPhotosController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    
    @hotel_photo = HotelPhoto.new(picture: params[:picture], hotel_id: params[:hotel_id])
    
    respond_to do |format|
      if @hotel_photo.save
        format.json { render json: @hotel_photo, status: 200 }
      else
        format.json { render json: @hotel_photo.errors, status: 500 }
      end
    end
  end
  
  def destroy
    @hotel_photo = HotelPhoto.find(params[:id])
    
    @hotel_photo.destroy unless params[:status] == "error"  
    
    respond_to do |format|
      format.json { render json: 'success', status: 200 }
    end    
  end
  
end
