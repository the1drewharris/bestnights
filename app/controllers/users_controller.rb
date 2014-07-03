class UsersController < ApplicationController
  include Devise::Controllers::Rememberable
  
  before_filter :authenticate_user!, except: [:create, :new]
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    @users = User.search(params[:search])
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end

  def subregion_options
    render partial: 'test'
  end
  
  def create
    @user = User.new(params[:user])
    # @user.role = params[:role]
    if @user.save
      flash[:success] = "The user was saved successfully!"
      redirect_to users_path and return
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to :back 
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    
    user = User.find(params[:id])
    is_current_user = false
    if current_user == user
      is_current_user = true
    end
    
    if current_user.admin? and !is_current_user
      #TODO Must add better "activation" here as it is failing and giving an error because required fields are not being sent
      user.update_attributes!(params[:user])
      AdminMailer.user_changed_notify(current_user, user).deliver
      redirect_to users_path and return
    else
      if user.valid_password?(params[:old_password])
        # attr = params[:user].merge("role" => params[:role])
        
        user.update_attributes!(params[:user])
        
        sign_in(user, :bypass => true) if is_current_user
        redirect_to users_path and return
      else
        redirect_to :back
      end      
    end
  end
  
  def new_manager
    @manager = User.new
  end
  
  def create_manager
    @manager = User.new(params[:user])
    @manager.role = 2
    if @manager.save!
      flash[:success] = "The manager was saved successfully!"
      redirect_to new_manager_path
    else
      redirect_to :back  
    end
  end
  
  
end
