class UsersController < ApplicationController
  before_filter :authenticate_user!
  layout "admin_basic", only: [:new_manager]
  
  def new_manager
    @manager = User.new
  end
  
  def create_manager
    @manager = User.new(params[:user])
    @manager.role = 2
    if @manager.save!
      flash[:success] = "The hotel saved successfully!"
      redirect_to new_manager_path
    else
      redirect_to :back  
    end
  end
  
  def show
    
  end
  def destroy
    
  end
  
end
