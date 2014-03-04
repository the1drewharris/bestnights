class RoomTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    @room_types = RoomType.all
  end
  
  def show
    @room_type = RoomType.find(params[:id])
  end
  
  def new
    @room_type = RoomType.new
  end
  
  def create
    @room_type = RoomType.new(params[:room_type])
    if @room_type.save
      AdminMailer.new_room_type_request(User.admins, @room_type, current_user).deliver if current_user.manager?
      flash[:success] = "The room type saved successfully!"
      redirect_to room_types_path
    else
      flash[:errors] = @room_type.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @room_type = RoomType.find(params[:id])    
  end
  
  def update
    room_type = RoomType.find(params[:id])
    if room_type.update_attributes(params[:room_type])
      AdminMailer.room_type_changed_notify(User.managers, room_type, current_user).deliver if current_user.admin?
      flash[:success] = "The room type saved successfully!"
      redirect_to room_types_path
    else
      flash[:errors] = room_type.errors.full_messages
      redirect_to :back 
    end
  end
  
  def destroy
    RoomType.find(params[:id]).destroy
    redirect_to room_types_path
  end
end