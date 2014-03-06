class RoomsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    if current_user.admin?
      @rooms = Room.search(params[:search])
    elsif current_user.manager? 
      @rooms = current_user.rooms.search(params[:search])
    end    
    
    if current_user.new_signup?
      @hotel = Hotel.find(params[:hotel_id])
      @rooms = @hotel.rooms    
    end
  end
  
  def show
    @room = Room.find(params[:id])
    @room_attributes = @room.room_attributes
    
  end
  
  def new
    @room = Room.new
    @room_types = RoomType.activated
    if current_user.admin?
      @hotels = Hotel.activated
    elsif current_user.manager?
      @hotels = current_user.activated_hotels
    end
    
    if current_user.new_signup?
      @hotel = Hotel.find(params[:hotel_id])
    end
  end
  
  def create
    @room = Room.new(params[:room])
    if @room.save
      flash[:success] = "The room type saved successfully!"
      
      if current_user.new_signup?
        redirect_to rooms_path(:hotel_id => @room.hotel.id)  
      else
        redirect_to rooms_path
      end      
    else
      flash[:errors] = @room.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @room = Room.find(params[:id])    
    @room_attributes = RoomAttribute.all
    if current_user.admin?
      @hotels = Hotel.activated
    elsif current_user.manager?
      @hotels = current_user.activated_hotels
    end
    
    if current_user.new_signup?
      @hotel = @room.hotel
    end
    
    @photos = @room.room_photos
    
  end
  
  def update
    room = Room.find(params[:id])
     
    if room.update_attributes(params[:room])
      if params[:client] and params[:client][:attributes]
        ## add new hotel attribute to the hotel
        params[:client][:attributes].keys.each do |room_attribute_id|
          RoomAttributeJoin.find_or_create_by_room_id_and_room_attribute_id(room.id, room_attribute_id)
        end
        
        # remove hotel attributes not to belong to the hotel from HotelAttributeJoin
        room.room_attributes.each do |ra|
          unless params[:client][:attributes].keys.include?(ra.id.to_s)
            room.room_attributes.delete(ra)
          end
        end
      end
      flash[:success] = "The room type saved successfully!"
      
      if current_user.new_signup?
        redirect_to rooms_path(:hotel_id => room.hotel.id)  
      else
        redirect_to rooms_path
      end  
    else
      flash[:errors] = room.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    room = Room.find(params[:id])
    hotel = room.hotel
    room.destroy
    
    if current_user.new_signup?
      redirect_to rooms_path(:hotel_id => hotel.id)  
    else
      redirect_to rooms_path
    end 
  end
end