class CardsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    @cards = Card.all
  end
  
  def show
    @card = Card.find(params[:id])
  end
  
  def new
    @card = Card.new
  end
  
  def create
    @card = Card.create(params[:card])
    if @card.save
      flash[:success] = "The card saved successfully!"
      redirect_to cards_path
    else
      flash[:errors] = @card.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @card = Card.find(params[:id])
  end
  
  def update
    card = Card.find(params[:id])
    
    if card.update_attributes(params[:card])
      flash[:success] = "The card updated successfully!"
      redirect_to cards_path
    else
      flash[:errors] = card.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Card.find(params[:id]).destroy
    redirect_to cards_path
  end
end