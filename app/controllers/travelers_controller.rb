class TravelersController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:index, :new, :show, :edit]
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
      redirect_to book_hotel_path
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
      flash[:success] = "The room type saved successfully!"
      redirect_to travelers_path
    else
      flash[:errors] = traveler.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Traveler.find(params[:id]).destroy
    redirect_to travelers_path
  end
end