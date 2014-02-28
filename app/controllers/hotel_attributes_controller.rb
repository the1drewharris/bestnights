class HotelAttributesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    if current_user.admin?
      @hotel_attributes = HotelAttribute.all
    elsif current_user.manager?
      @hotel_attributes = current_user.hotel_attributes
    end 
  end
  
  def show
    @hotel_attribute = HotelAttribute.find(params[:id])
  end
  
  def new
    @hotel_attribute = HotelAttribute.new
  end
  
  def create
    @hotel_attribute = HotelAttribute.create(params[:hotel_attribute])
    if @hotel_attribute.save
      flash[:success] = "The hotel attribute saved successfully!"
      redirect_to hotel_attributes_path
    else
      flash[:errors] = @hotel_attribute.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @hotel_attribute = HotelAttribute.find(params[:id])
  end
  
  def update
    hotel_attribute = HotelAttribute.find(params[:id])
    if hotel_attribute.update_attributes(params[:hotel_attribute])
      flash[:success] = "The hotel attribute saved successfully!"
      redirect_to hotel_attributes_path  
    else
      flash[:errors] = hotel_attribute.errors.full_messages
      redirect_to :back
    end
  end
  
  def destroy
    HotelAttribute.find(params[:id]).destroy
    redirect_to hotel_attributes_path
  end
end