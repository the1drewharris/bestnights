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
      redirect_to request.referer
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update   
    if current_user && current_user.admin?
      @user = User.find_by_id(params[:id])
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank? && current_user.encrypted_password
      #TODO Must add better "activation" here as it is failing and giving an error because required fields are not being sent
        if @user.update_attributes(params[:user])
          # AdminMailer.user_changed_notify(current_user, @user).deliver
          redirect_to users_path 
        else
          render :action => :edit
        end
      elsif current_user.encrypted_password
        @user.update_attributes(params[:user])
        # AdminMailer.user_changed_notify(current_user, @user).deliver
        redirect_to users_path
      end
    elsif current_user.manager?
      if current_user.valid_password?(params[:old_password])        
        current_user.update_attributes(params[:user])        
        redirect_to my_hotels_path
      else
        redirect_to request.referer
      end
    else
      if @user.valid_password?(params[:old_password])
        @user.update_attributes(params[:user])       
        redirect_to users_path
      else
        redirect_to request.referer
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
      redirect_to request.referer 
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end
  
  
end
