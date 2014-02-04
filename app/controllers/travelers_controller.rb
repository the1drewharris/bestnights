class TravelersController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
  
  def new
    @traveler = Traveler.new
  end
  
  def create
    @traveler = Traveler.create(params[:traveler])
    if @traveler.save!
      flash[:success] = "The room type saved successfully!"
      redirect_to new_traveler_path
    else
      redirect_to :back  
    end
  end
end