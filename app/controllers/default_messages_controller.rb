class DefaultMessagesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    @default_messages = DefaultMessage.all
  end
  
  def show
    @default_message = DefaultMessage.find(params[:id])
  end
  
  def new
    @default_message = DefaultMessage.new
  end
  
  def create
    @default_message = DefaultMessage.create(params[:default_message])
    if @default_message.save
      flash[:success] = "The default message saved successfully!"
      redirect_to default_messages_path
    else
      flash[:errors] = @default_message.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @default_message = DefaultMessage.find(params[:id])
  end
  
  def update
    default_message = DefaultMessage.find(params[:id])
    
    if default_message.update_attributes(params[:default_message])
      flash[:success] = "The default message updated successfully!"
      redirect_to default_messages_path
    else
      flash[:errors] = default_message.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    DefaultMessage.find(params[:id]).destroy
    redirect_to default_messages_path
  end
end