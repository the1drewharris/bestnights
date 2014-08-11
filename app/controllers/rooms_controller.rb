class RoomsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  layout "admin_basic"
  
  def index
    if (current_user.manager? && !params[:search].blank?) || (current_user.admin? && !params[:search].blank?)
        @rooms = Room.find(:all, :conditions => ['(id LIKE ? or name LIKE ? or description LIKE ?)', "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"])
    elsif current_user.admin?
      @rooms = Room.all
    elsif current_user.manager? 
      @rooms = current_user.rooms
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
    @room.price = params[:room][:price].to_f + params[:room][:additionaladultfee].to_f
    if @room.save
      @room_available = RoomAvailable.find_by_room_type_id_and_hotel_id(params[:room][:room_type_id],session[:hotel_id])
      unless @room_available.blank?
        @room_available.number += params[:room][:starting_inventory].to_i
      else
        @room_available = RoomAvailable.new
        @room_available.room_type_id = params[:room][:room_type_id]
        @room_available.number = params[:room][:starting_inventory].to_i
        @room_available.hotel_id = session[:hotel_id]
      end
      @room_available.save
      flash[:success] = "The room type saved successfully!"
      if current_user.new_signup?
        redirect_to rooms_path(:hotel_id => @room.hotel.id)  
      else
        redirect_to rooms_path
      end      
    else
      flash[:errors] = @room.errors.full_messages
      redirect_to request.referer  
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
      @room_rate = RoomRate.find_by_room_type_id(room.room_type.id)
      if @room_rate.nil?
        @room_rate = RoomRate.new
        @room_rate.room_id = params[:id] 
        @room_rate.room_type_id = room.room_type_id
        @room_rate.hotel_id = room.hotel_id
      end
      @room_rate.save
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

  def rate_details
    session[:room_id]  = params[:room_id]
    @rate_detail = RoomRateDetail.find_by_room_id(session[:room_id])
  end

  def add_room_rate_details
    if @rate_detail = RoomRateDetail.find_by_room_id(session[:room_id])
    else
      @rate_detail = RoomRateDetail.new
    end
    if !params[:to_date].blank? 
      @rate_detail.to_date = DateTime.strptime(params[:to_date], '%m/%d/%Y').to_date
    else
      @rate_detail.to_date = ""
    end

    if !params[:from_date].blank? 
      @rate_detail.from_date = DateTime.strptime(params[:from_date], '%m/%d/%Y').to_date
    else
      @rate_detail.from_date = ""
    end
    @rate_detail.day = params[:day]
    @rate_detail.status = params[:status]
    @rate_detail.rate_per_night = params[:rate_per_night]
    @rate_detail.booked = params[:booked]
    @rate_detail.canceled = params[:canceled]
    @rate_detail.policy_group = params[:policy_group]
    @rate_detail.month = params[:month]
    @rate_detail.year = params[:year]
    @rate_detail.rooms_to_sell = params[:rooms_to_sell]
    @rate_detail.room_id = session[:room_id]

    respond_to do |format|
      if @rate_detail.save!
        format.html { redirect_to rooms_path, notice: 'rate Details successfully created.' }
        format.json { render json: @rate_detail, status: :created, location: @rate_detail }
      else
        logger.info"&&&&&&&&&&&&&&&&&&&&&&&&&7"
        format.html { render action: "rate_details", notice: 'Please fill all the information.' }
        format.json { render json: @rate_detail.errors, status: :unprocessable_entity }
      end
    end    
  end
end
