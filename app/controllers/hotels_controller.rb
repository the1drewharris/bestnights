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
    if @hotels.blank?
      flash[:success] = "Hotels Not Found"
    end
  end
  
  def show
      @hotel = Hotel.find(params[:id])
      @hotel_photos = @hotel.hotel_photos
      @hotel_attributes = @hotel.hotel_attributes.order('attr')
  end

  def new
    @hotel = Hotel.new 
  end

  def subregion_options
    render partial: 'test'
  end

  def create
    @hotel = Hotel.new(params[:hotel])
    if !params[:traveler].nil?
      @hotel.state_id = params[:traveler][:state_id]
    end
    # @hotel.status = "non-active" unless params[:hotel][:status]
    # @hotel.comission_rate = 14 unless params[:hotel][:comission_rate]
    
    if current_user.manager?
      @hotel.user_id = current_user.id
    end
    
    if @hotel.save
      
      if current_user.admin?
        AdminMailer.new_hotel_request([@hotel.user], @hotel, current_user).deliver
        flash[:success] = "The hotel saved successfully!"
        redirect_to hotels_path
      elsif current_user.manager?
        AdminMailer.new_hotel_request(User.admins, @hotel, current_user).deliver
        flash[:success] = "The hotel saved successfully!"
        redirect_to my_hotels_path
      end
      
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
        AdminMailer.hotel_changed_notify(hotel.user, hotel, current_user).deliver
        if hotel.user.status == 'pending'
          hotel.user.update_attributes(status: 'active')
        end
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
      
      #flash[:success] = "The hotel updated successfully!"
      respond_to do |format|
        flash[:success] = "The hotel updated successfully!"
        format.html { redirect_to hotels_path }
        format.json { render json: @hotel }
      end
      #redirect_to hotels_path
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
    
    AdminMailer.registered_frontdesk_request(current_user, hotel).deliver
    
    flash[:success] = "The hotel was registered successfully!"
    redirect_to hotels_path
  end

  def confirm
    @hotel = Hotel.find_by_id(params[:hotel_id])
    @hotel.status = "active"
    @hotel.save(validate: false)
    redirect_to request.referer
  end

  def make_pending
    @hotel = Hotel.find_by_id(params[:hotel_id])
    @hotel.status = "pending"
    @hotel.save(validate: false)
    redirect_to request.referer
  end 

  def edit_commission_rate
    @commission_rate = CommissionRate.find_by_hotel_id(params[:hotel_id])
  end
end
