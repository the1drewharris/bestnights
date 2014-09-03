class PromotionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource  
  layout "admin_basic", only: [:index, :new, :show, :edit]
  
  def index
    if current_user.admin?
      @promotions = Promotion.all
    elsif current_user.manager?
      @promotions = current_user.promotions
    end 
  end
  
  def show
    @promotion = Promotion.find(params[:id])
  end
  
  def new
    @promotion = Promotion.new
    if current_user.admin?
      @hotels = Hotel.all
    elsif current_user.manager?
      @hotels = current_user.hotels
    end
  end
  
  def create
    start_date = params[:startdate].to_time
    if params[:startampm] == "AM"
      starthour = params[:starthour]
    else
      starthour = params[:starthour].to_i + 12
    end
    start_date.change({:hour => starthour, :min => params[:startminute]}) unless start_date.nil?
    end_date = params[:enddate].to_time
    if params[:endampm] == "AM"
      endhour = params[:endhour]
    else
      endhour = params[:endhour].to_i + 12
    end
    end_date.change({:hour => endhour, :min => params[:endminute]}) unless end_date.nil?
    
    @promotion = Promotion.new(params[:promotion])
    @promotion.start_date = start_date
    @promotion.expiry_date = end_date
    if @promotion.save
      flash[:success] = "The promotion saved successfully!"
      redirect_to promotions_path
    else
      flash[:errors] = @promotion.errors.full_messages
      redirect_to :back  
    end
  end
  
  def edit
    @promotion = Promotion.find(params[:id])
    if current_user.admin?
      @hotels = Hotel.all
    elsif current_user.manager?
      @hotels = current_user.hotels
    end
  end
  
  def update
    promotion = Promotion.find(params[:id])
    if promotion.update_attributes(params[:promotion])
      flash[:success] = "The promotion saved successfully!"
      redirect_to promotions_path
    else
      flash[:errors] = @promotion.errors.full_messages
      redirect_to :back  
    end
  end
  
  def destroy
    Promotion.find(params[:id]).destroy
    redirect_to promotions_path
  end
end