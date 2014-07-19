class TravelersController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  layout "traveler_basic", only: [:booking_history, :edit_traveler, :show]
  def index
    @travelers = Traveler.search(params[:search])
  end
  
  def show
    @traveler = Traveler.find(params[:id])
  end
  
  def new
    @traveler = Traveler.new
  end
  
  def travelers_login
    
  end

  def traveler_login_create
   @traveler = Traveler.find_by_email(params[:email])
    session[:traveler] = @traveler
    if @traveler and @traveler.valid_password?(params[:password])
      session[:traveler_id] = @traveler.id
      redirect_to traveler_path(@traveler.id)
    else
      flash[:success] = "Wrong Credential"
      redirect_to travelers_login_path
    end 
  end

  def create
    @traveler = Traveler.new(params[:traveler])
    if @traveler.save
      flash[:success] = "The room type saved successfully!"
      redirect_to travelers_path
    else
      flash[:errors] = @traveler.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @traveler = Traveler.find(params[:id])
  end
  
  def update
    traveler = Traveler.find(params[:id])    
    if traveler.update_attributes(params[:traveler])
      flash[:success] = "The traveler updated successfully!"
      if session[:traveler_id]
        redirect_to book_hotel_path
      else
        redirect_to travelers_path
      end 
    else
      flash[:errors] = traveler.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Traveler.find(params[:id]).destroy
    redirect_to travelers_path
  end

  def booking_history
    @booking_histories = Booking.where("traveler_id=?", params[:traveler_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
  end

  def edit_traveler
    @traveler = Traveler.find(params[:id])
    session[:traveler_id] = @traveler.id
  end
end