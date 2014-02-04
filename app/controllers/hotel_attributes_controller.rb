class HotelAttributesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
  
  def new
    @hotel_attribute = HotelAttribute.new
  end
  
  def create
    @hotel_attribute = HotelAttribute.create(params[:hotel_attribute])
    if @hotel_attribute.save!
      flash[:success] = "The hotel saved successfully!"
      redirect_to new_hotel_attribute_path
    else
      redirect_to :back  
    end
  end
end