class DashboardController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    
  end

  def arrivals
    if params[:day] == "todays" || params[:day].blank? 
  	 @arrivals = Booking.where(:from_date => Date.today).paginate(:page => params[:page], :per_page => 20).order('id DESC')
  	elsif params[:day] == "yesterday"
     @arrivals = Booking.where(:from_date => Date.yesterday).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    elsif params[:day] == "future"
     @arrivals = Booking.where('from_date > ?', Date.today ).paginate(:page => params[:page], :per_page => 20).order('id DESC')
     end
  end

  def bookings
  	@bookings = Booking.paginate(:page => params[:page], :per_page => 20).order('id DESC')

  end
end
