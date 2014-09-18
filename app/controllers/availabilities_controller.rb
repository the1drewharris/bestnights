class AvailabilitiesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    if current_user.admin?
      @availabilities = Availability.order("created_at desc")
      
    elsif current_user.manager?
      @availabilities = current_user.availabilities
    end
  end
  
  def show
    @availability = Availability.find(params[:id])
  end
  
  def new
    @availability = Availability.new
    @count = params[:count]
    if current_user.admin?
      @rooms = Room.all
    elsif current_user.manager?
      @rooms = current_user.rooms
    end
  end
  
  def create
    @availability = Availability.new(params[:availability])
    
    if params[:availability][:count].to_i > params[:availability][:starting_inventory].to_i
      flash[:errors] = ["count must not be greater than the starting inventory"]
      redirect_to :back and return
    end 
    
    if @availability.save
      flash[:success] = "The availability saved successfully!"
      redirect_to availabilities_path
    else
      flash[:errors] = @availability.errors.full_messages
      render :action=>'new' 
    end

  end
  
  def edit
    @availability = Availability.find(params[:id]) 
    if current_user.admin?
      @rooms = Room.all
    elsif current_user.manager?
      @rooms = current_user.rooms
    end   
  end
  
  def update
    availability = Availability.find(params[:id])
    
    if params[:availability][:count].to_i > params[:availability][:starting_inventory].to_i
      flash[:errors] = ["count must not be greater than the starting inventory"]
      redirect_to :back and return
    end 
     
    if availability.update_attributes(params[:availability])      
      flash[:success] = "The availability saved successfully!"
      redirect_to availabilities_path  
    else
      flash[:errors] = availability.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Availability.find(params[:id]).destroy
    redirect_to availabilities_path
  end
  
  def grid
    if current_user.admin?
      @rooms = Room.all
    elsif current_user.manager?
      @rooms = current_user.rooms
    end 
  end
  
  def days
    if current_user.admin?
      @rooms = Room.all
    elsif current_user.manager?
      @rooms = current_user.rooms
    end 
  end
  
end