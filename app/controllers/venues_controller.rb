class VenuesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    @venues = Venue.all
  end
  
  def show
    @venue = Venue.find(params[:id])
  end
  
  def new
    @venue = Venue.new
  end
  
  def create
    @venue = Venue.create(params[:venue])
    if @venue.save
      flash[:success] = "The venue saved successfully!"
      redirect_to venues_path
    else
      flash[:errors] = @venue.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @venue = Venue.find(params[:id])
  end
  
  def update
    venue = Venue.find(params[:id])
    
    if venue.update_attributes(params[:venue])
      flash[:success] = "The venue updated successfully!"
      redirect_to venues_path
    else
      flash[:errors] = venue.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Venue.find(params[:id]).destroy
    redirect_to venues_path
  end
end