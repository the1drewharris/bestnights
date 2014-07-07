class DashboardController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!
  layout "admin_basic"
  
  def index
    unless !session[:hotel_id].blank? 
      session[:hotel_id] = params[:hotel_id]
    else
      session[:hotel_id] = session[:hotel_id]
    end
    @hotel = Hotel.find(session[:hotel_id])
    session[:hotel_name] = @hotel.name
  end

  def my_hotels
    if current_user.admin?
      @hotels = Hotel.all
    elsif current_user.manager?
      @hotels = current_user.hotels
    end 
  end

  def arrivals
    if !params[:search_date].blank?
      @arrivals = Booking.where("from_date=?", params[:search_date].to_date ).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    end
    unless !session[:hotel_id].blank? 
      session[:hotel_id] = params[:hotel_id]
    else
      session[:hotel_id] = session[:hotel_id]
    end
    @hotel = Hotel.find(session[:hotel_id])
    session[:hotel_name] = @hotel.name

    if params[:day] == "todays" || params[:day].blank? && params[:search_date].blank?
  	 @arrivals = Booking.where("hotel_id=? AND from_date=?", session[:hotel_id], Date.today ).paginate(:page => params[:page], :per_page => 20).order('id DESC')
  	elsif params[:day] == "yesterday"
     @arrivals = Booking.where("hotel_id=? AND from_date=?", session[:hotel_id], Date.yesterday).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    elsif params[:day] == "future"
     @arrivals = Booking.where("hotel_id=? AND from_date > ?", session[:hotel_id], Date.today).paginate(:page => params[:page], :per_page => 20).order('id DESC')
     end
  end

  def bookings
  	@bookings = Booking.where(:hotel_id => session[:hotel_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
  end

  def statistics
    @site_visitors_today = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE created_at=CURDATE()")
    @site_visitors_this_week = ActiveRecord::Base.connection.exec_query("SELECT * FROM impressions  WHERE created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY)")
    @site_visitors_this_month = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())")
    @site_visitors_this_year = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE YEAR(created_at) = YEAR(CURDATE())")
    @bookings_day_wise = Booking.where("created_at >= ?", Date.today)
    @bookings_week_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY)")
    @bookings_month_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH)")
    @bookings_year_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR)")
    @total_nights_today = find_nights_today
    @total_nights_this_week = find_nights_this_week
    @total_nights_this_month = find_nights_this_month
    @total_nights_this_year = find_nights_this_year
  end

  def download_booking_data
    # @bookings = Booking.all
    # respond_to do |format|
    #   format.csv { send_data Booking.to_csv }
    #   format.xls { send_data @bookings.to_csv(col_sep: "\t") }
    # end
    @bookings = Booking.where(:hotel_id => session[:hotel_id])
    csv_string = CSV.generate do |csv|
       csv << ["Booking_Number", "Total", "Arrival","Departure", "Booker_Name", "Night_Number", "Booking_Date"]
       @bookings.each do |book|
         csv << [book.id, book.price, book.from_date, book.to_date, book.traveler.name, book.night_number, book.created_at]
       end
    end   
   send_data csv_string,
   :type => 'text/csv; charset=iso-8859-1; header=present',
   :disposition => "attachment; filename=bookings.csv"
  end

  def export_in_excel
    @bookings = Booking.where(:hotel_id => session[:hotel_id])
    csv_string = CSV.generate do |csv|
       csv << ["Booking_Number", "Total", "Arrival","Departure", "Booker_Name", "Night_Number", "Booking_Date"]
       @bookings.each do |book|
         csv << [book.id, book.price, book.from_date, book.to_date, book.traveler.name, book.night_number, book.created_at]
       end
    end   
   send_data csv_string,
   :type => 'text/xls; charset=iso-8859-1; header=present',
   :disposition => "attachment; filename=bookings.xls"
  end

  def overview
    # @rooms = Booking.where(:hotel_id => session[:hotel_id])
    # cookies[:from_date] = []
    # cookies[:to_date] = []
    # cookies[:nights] = []
    # @rooms.each do |room|
    #   @booked = Booking.find_by_hotel_id_and_room_id(room.hotel_id,room.room_id)
    #   cookies[:from_date] << @booked.from_date
    #   cookies[:to_date] << @booked.to_date
    #   (@booked.from_date..@booked.to_date).to_a.select{|k| cookies[:nights] << k}
    # end
    @room_types = RoomType.all
  end

  def cancel_booking
    
  end

  def finance
    unless !session[:hotel_id].blank?
      logger.info"*********#{params[:hotel_id]}***********"
      session[:hotel_id] = params[:hotel_id]
    else
      session[:hotel_id] = session[:hotel_id]
    end
  end

  def invoice
    @commission_rate = CommissionRate.amount
    @bookings = Booking.where(:hotel_id => session[:hotel_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    @bookings.each do |booking|
      booking.price = (booking.price.to_i * (@commission_rate).to_f) / 100
    end
  end

  def status
    @booking = Booking.find_by_id(params[:id])
    @booking.price = (@booking.price.to_i * 12) / 100
    @room = Room.find_by_id(@booking.room_id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "invoice_status"
      end
    end
  end

  def reservation_statements
    @commission_rate = CommissionRate.first
    if params[:from_date]
      @bookings = Booking.where("hotel_id=? AND from_date=?", session[:hotel_id], params[:from_date]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    else
      @bookings = Booking.where(:hotel_id => session[:hotel_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    end
    @bookings.each do |booking|
      @reserve_price = (booking.price.to_i * (@commission_rate.amount).to_f) / 100
    end
    @periods = Booking.all
    @period_array = []
    @periods.each do |period|
      str = period.from_date.to_s + " To " + period.to_date.to_s
      @period_array << str
    end
  end

  def download_reservation_data
    @bookings = Booking.where(:hotel_id => session[:hotel_id])
    @commission_rate = CommissionRate.first
    csv_string = CSV.generate do |csv|
       csv << ["Booking_Number", "Booked_By", "Guest_Name","Checkin", "Checkout", "Room_Nights", "Commission", "Result", "Original_Amount", "Final_Amount", "Commission_Amount", "Remarks"]
       @bookings.each do |book|
          @reserve_price = (book.price.to_i * (@commission_rate.amount).to_f) / 100
          csv << [book.id, book.traveler.name, book.traveler.name, book.from_date, book.to_date, book.night_number, @commission_rate.amount, "", book.price, book.price.to_f - @reserve_price.to_f, @reserve_price, ""]
       end
    end   
   send_data csv_string,
   :type => 'text/csv; charset=iso-8859-1; header=present',
   :disposition => "attachment; filename=bookings.csv"
  end

  def export_reservation_in_excel
    @bookings = Booking.where(:hotel_id => session[:hotel_id])
    @commission_rate = CommissionRate.first
    csv_string = CSV.generate do |csv|
       csv << ["Booking_Number", "Booked_By", "Guest_Name","Checkin", "Checkout", "Room_Nights", "Commission", "Result", "Original_Amount", "Final_Amount", "Commission_Amount", "Remarks"]
       @bookings.each do |book|
          @reserve_price = (book.price.to_i * (@commission_rate.amount).to_f) / 100
          csv << [book.id, book.traveler.name, book.traveler.name, book.from_date, book.to_date, book.night_number, @commission_rate.amount, "", book.price, book.price.to_f - @reserve_price.to_f, @reserve_price, ""]
       end
    end
    send_data csv_string,
    :type => 'text/xls; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=bookings.xls"
  end

  def download_reservation_data_month
    @bookings = Booking.where("MONTH(created_at)=?",cookies[:month].to_i)
    @bookings.each do |booking|
      @room = Room.find_by_id(booking.room_id)
      booking.room_type = @room.room_type
      booking.save
    end
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "monthly_invoice_status"
      end
    end
  end

  def finance_info
    
  end

  def invoicing_details
    @hotel = Hotel.find(session[:hotel_id])    
  end

  def find_room_details
    date = "rate_" + params[:date].to_date.strftime("%A").downcase
    @roomtypes = RoomType.all
    @rooms = []
    @finds = {}
    a = []
    a1 = []
    @roomtypes.each_with_index do|roomtype,i|
      @rate = ActiveRecord::Base.connection.exec_query("SELECT "+date+" FROM room_rates WHERE room_type_id ="+roomtype.id.to_s+" ")
      if @rate.rows.empty?
        @p1 = {"rate_#{i}" =>  ""}
        a << @p1
      else
        @p2 ={"rate_#{i}" =>  @rate.rows[0][0]}
        a1 << @p2
      end
    end
    a << a1
    b = []
    @bookings = Booking.where("hotel_id=? AND from_date=?",session[:hotel_id], params[:date])
    @bookings.each_with_index do |booking|
      @rooms << Room.where("id=?", booking.room_id)
    end
    @room_types = @rooms.flatten.collect(&:room_type_id).uniq
    @room_types.each do |room_type|
      @count = 0
      @rooms.flatten.each do |room|
        if room.room_type_id == room_type
          @count += 1
        end
      end
      @book = {"#{room_type}" => @count}
      b << @book
    end
    @finds = {rates: a.reverse.flatten, booked: b}
    respond_to do |format|
      format.json{render json: @finds}
    end
  end

  private

  def find_nights_today
    @bookings_today = Booking.all(:conditions => ["created_at >= ?", Date.today])
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

  def find_nights_this_week
    @bookings_today =  Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY)")
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

  def find_nights_this_month
    @bookings_today =  Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH)")
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

  def find_nights_this_year
    @bookings_today =  Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR)")
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

end


# ActiveRecord::Base.connection.exec_query("SELECT count( * ) FROM bookings WHERE year( created_at ) = '2014' GROUP BY year( created_at )")
#sum(rating_for_customer_relationship) as customer_relationship