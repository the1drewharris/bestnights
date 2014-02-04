class HotelsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  layout "admin_basic", only: [:new]
  
  def index
    @hotels = Hotel.all
  end
  
  def show
    @hotel = Hotel.find(params[:id])
  end

  def new
    @hotel = Hotel.new
  end

  def create
    @hotel = Hotel.create(params[:hotel])
    if @hotel.save!
      flash[:success] = "The hotel saved successfully!"
      redirect_to new_hotel_path
    else
      redirect_to :back  
    end
    
  end
end
