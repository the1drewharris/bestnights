class RoomAttributesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
  
  def new
    @room_attribute = RoomAttribute.new
  end
  
  def create
    @room_attribute = RoomAttribute.create(params[:room_attribute])
    if @room_attribute.save!
      flash[:success] = "The hotel saved successfully!"
      redirect_to new_room_attribute_path
    else
      redirect_to :back  
    end
  end
end