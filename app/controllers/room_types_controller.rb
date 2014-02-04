class RoomTypesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
  
  def new
    @room_type = RoomType.new
  end
  
  def create
    @room_type = RoomType.create(params[:room_type])
    if @room_type.save!
      flash[:success] = "The room type saved successfully!"
      redirect_to new_room_type_path
    else
      redirect_to :back  
    end
  end
end