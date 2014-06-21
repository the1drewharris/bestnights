class DashboardController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!
  layout "admin_basic"
  
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
    @total_nights = Booking.all(:conditions => ["created_at >= ?", Date.today]).map(&:night_number).sum
  end

  def download_booking_data
    # @bookings = Booking.all
    # respond_to do |format|
    #   format.csv { send_data Booking.to_csv }
    #   format.xls { send_data @bookings.to_csv(col_sep: "\t") }
    # end
    @bookings = Booking.all
    csv_string = CSV.generate do |csv|
       csv << ["Booking Number", "Total", "Arrival","Departure", "Booker Name", "Night Number", "Booking Date"]
       @bookings.each do |book|
         csv << [book.id, book.price, book.from_date, book.to_date, book.traveler.name, book.night_number, book.created_at]
       end
    end   
   send_data csv_string,
   :type => 'text/csv; charset=iso-8859-1; header=present',
   :disposition => "attachment; filename=bookings.csv"
  end

  def export_in_excel
    @bookings = Booking.all
    csv_string = CSV.generate do |csv|
       csv << ["Booking Number", "Total", "Arrival","Departure", "Booker Name", "Night Number", "Booking Date"]
       @bookings.each do |book|
         csv << [book.id, book.price, book.from_date, book.to_date, book.traveler.name, book.night_number, book.created_at]
       end
    end   
   send_data csv_string,
   :type => 'text/xls; charset=iso-8859-1; header=present',
   :disposition => "attachment; filename=bookings.xls"
  end

end


# ActiveRecord::Base.connection.exec_query("SELECT count( * ) FROM bookings WHERE year( created_at ) = '2014' GROUP BY year( created_at )")
#sum(rating_for_customer_relationship) as customer_relationship