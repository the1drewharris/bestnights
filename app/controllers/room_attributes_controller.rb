class RoomAttributesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    @room_attributes = RoomAttribute.search(params[:search])
  end
  
  def show
    @room_attribute = RoomAttribute.find(params[:id])
  end
  
  def new
    @room_attribute = RoomAttribute.new
  end
  
  def create
    @room_attribute = RoomAttribute.create(params[:room_attribute])
    if @room_attribute.save
      flash[:success] = "The Room Attributes saved successfully!"
      redirect_to room_attributes_path
    else
      flash[:errors] = @room_attribute.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @room_attribute = RoomAttribute.find(params[:id])
  end
  
  def update
    room_attribute = RoomAttribute.find(params[:id])
    if room_attribute.update_attributes(params[:room_attribute])
      flash[:success] = "The Room Attributes saved successfully!"
      redirect_to room_attributes_path
    else
      flash[:errors] = room_attribute.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    RoomAttribute.find(params[:id]).destroy
    redirect_to room_attributes_path
  end
end