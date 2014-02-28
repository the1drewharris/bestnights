class HotelsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    if current_user.admin?
      @hotels = Hotel.search(params[:search])
    elsif current_user.manager?
      @hotels = current_user.hotels.search(params[:search])
    end 
    
    if current_user.front_desk?
      if params[:search].nil? or params[:search].empty?
        @hotels = [current_user.hotel]
      else
        @hotels = Hotel.search(params[:search])
      end
    end
  end
  
  def show
    @hotel = Hotel.find(params[:id])
    @hotel_photos = @hotel.hotel_photos
    @hotel_attributes = @hotel.hotel_attributes
  end

  def new
    @hotel = Hotel.new  
    
    # render :layout => 'admin_basic' unless current_user.new_signup?
  end

  def create
    @hotel = Hotel.new(params[:hotel])
    # @hotel.status = "non-active" unless params[:hotel][:status]
    # @hotel.comission_rate = 14 unless params[:hotel][:comission_rate]
    
    if current_user.manager?
      @hotel.user_id = current_user.id
    end
    
    if @hotel.save
      
      if current_user.admin?
        # AdminMailer.new_hotel_request([@hotel.user], @hotel, current_user).deliver
      elsif current_user.manager?
        # AdminMailer.new_hotel_request(User.admins, @hotel, current_user).deliver
      end
      
      flash[:success] = "The hotel saved successfully!"
      redirect_to hotels_path
    else
      flash[:errors] = @hotel.errors.full_messages
      redirect_to :back
    end
  end
  
  def edit
    @hotel = Hotel.find(params[:id])
    @hotel_attributes = HotelAttribute.all
    @photos = @hotel.hotel_photos
  end
  
  def update
    hotel = Hotel.find(params[:id])
    if hotel.update_attributes(params[:hotel])
      if current_user.admin?
        # AdminMailer.hotel_changed_notify(hotel.user, hotel, current_user).deliver
      end  
      
      if params[:client] and params[:client][:attributes]
        ## add new hotel attribute to the hotel
        params[:client][:attributes].keys.each do |hotel_attribute_id|
          HotelAttributeJoin.find_or_create_by_hotel_id_and_hotel_attribute_id(hotel.id, hotel_attribute_id)
        end
        
        # remove hotel attributes not to belong to the hotel from HotelAttributeJoin
        hotel.hotel_attributes.each do |ha|
          unless params[:client][:attributes].keys.include?(ha.id.to_s)
            hotel.hotel_attributes.delete(ha)
          end
        end
      end
      
      flash[:success] = "The hotel updated successfully!"
      redirect_to hotels_path
    else
      flash[:errors] = hotel.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Hotel.find(params[:id]).destroy
    redirect_to hotels_path
  end
  
  def register
    current_user.update_attributes({:hotel_id => params[:id]})
    hotel = Hotel.find(params[:id])
    
    # AdminMailer.registered_frontdesk_request(current_user, hotel).deliver
    
    flash[:success] = "The hotel was registered successfully!"
    redirect_to hotels_path
  end
  
end
