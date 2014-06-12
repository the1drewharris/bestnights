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

  def statistics
    @site_visitors = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions")
    @bookings_day_wise = Booking.all(:conditions => ["created_at >= ?", Date.today])
    @bookings_month_wise = Booking.all(:conditions => ["created_at >= ?", Date.today - 32 ])
    @bookings_year_wise = ActiveRecord::Base.connection.exec_query("Select count(*) as b FROM bookings WHERE year(created_at) = '2014' GROUP BY year(created_at)")
  end
end


# ActiveRecord::Base.connection.exec_query("SELECT count( * ) FROM bookings WHERE year( created_at ) = '2014' GROUP BY year( created_at )")
