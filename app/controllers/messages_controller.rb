class MessagesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
  
  def new
    @message = Message.new
  end
  
  def create
    @message = Message.create(params[:message])
    if @message.save!
      flash[:success] = "The hotel saved successfully!"
      redirect_to new_message_path
    else
      redirect_to :back  
    end
  end
end