class DashboardController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!
  layout "admin_basic"
  
  def index
    if !params[:hotel_id].blank?
      session[:hotel_id] = params[:hotel_id]
    elsif !session[:hotel_id].blank? 
      session[:hotel_id] = session[:hotel_id]
    end
    @hotel = Hotel.find(session[:hotel_id])
    session[:hotel_name] = @hotel.name
    @hotel_view = HotelView.new
    if @hotel.status == "active" 
      @hotel_view.hotel_id = @hotel.id
      @hotel_view.save
    end
    # Hotel View
    @hotel_day_wise = HotelView.where("created_at >= ? AND hotel_id=?", Date.today, session[:hotel_id])
    @hotel_week_wise = HotelView.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND hotel_id=?",session[:hotel_id])
    @hotel_month_wise = HotelView.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND hotel_id=?", session[:hotel_id])
    @hotel_year_wise = HotelView.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND hotel_id=?", session[:hotel_id])
    #Statistics
    @site_visitors_today = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE created_at=CURDATE()")
    @site_visitors_this_week = ActiveRecord::Base.connection.exec_query("SELECT * FROM impressions  WHERE created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY)")
    @site_visitors_this_month = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())")
    @site_visitors_this_year = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE YEAR(created_at) = YEAR(CURDATE())")
    @bookings_day_wise = Booking.where("created_at >= ? AND hotel_id=?", Date.today, session[:hotel_id])
    @bookings_week_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND hotel_id=?",session[:hotel_id])
    @bookings_month_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND hotel_id=?", session[:hotel_id])
    @bookings_year_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND hotel_id=?", session[:hotel_id])
    @total_nights_today = find_nights_today
    @total_nights_this_week = find_nights_this_week
    @total_nights_this_month = find_nights_this_month
    @total_nights_this_year = find_nights_this_year

    #Arrivals
    unless !session[:hotel_id].blank? 
      session[:hotel_id] = params[:hotel_id]
    else
      session[:hotel_id] = session[:hotel_id]
    end
    @hotel = Hotel.find(session[:hotel_id])
    session[:hotel_name] = @hotel.name
    if params[:day] == "todays" || params[:day].blank?
     @arrivals = Booking.where("hotel_id=? AND from_date=?", session[:hotel_id], Date.today ).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    elsif params[:day] == "yesterday"
     @arrivals = Booking.where("hotel_id=? AND from_date=?", session[:hotel_id], Date.yesterday).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    elsif params[:day] == "future"
     @arrivals = Booking.where("hotel_id=? AND from_date > ?", session[:hotel_id], Date.today).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    end
  end

  def my_hotels
    if current_user.admin?
      @hotels = Hotel.search(params[:search])
    elsif current_user.manager?
      if params[:search]
        @hotels = current_user.hotels.search(params[:search])
      else
        @hotels = current_user.hotels
        if !@hotels.blank?
          if @hotels.count < 2 
            redirect_to dashboard_path(:hotel_id => current_user.hotels.first.id)
          end 
        end
      end
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
    @hotel = Hotel.find_by_id(session[:hotel_id])
  	@bookings = Booking.where(:hotel_id => session[:hotel_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
  end

  def statistics
    # Hotel View
    @hotel_day_wise = HotelView.where("created_at >= ? AND hotel_id=?", Date.today, session[:hotel_id])
    @hotel_week_wise = HotelView.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND hotel_id=?",session[:hotel_id])
    @hotel_month_wise = HotelView.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND hotel_id=?", session[:hotel_id])
    @hotel_year_wise = HotelView.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND hotel_id=?", session[:hotel_id])
    @site_visitors_today = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE created_at=CURDATE()")
    @site_visitors_this_week = ActiveRecord::Base.connection.exec_query("SELECT * FROM impressions  WHERE created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY)")
    @site_visitors_this_month = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())")
    @site_visitors_this_year = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as c from impressions WHERE YEAR(created_at) = YEAR(CURDATE())")
    @bookings_day_wise = Booking.where("created_at >= ? AND hotel_id=?", Date.today, session[:hotel_id])
    @bookings_week_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND hotel_id=?",session[:hotel_id])
    @bookings_month_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND hotel_id=?", session[:hotel_id])
    @bookings_year_wise = Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND hotel_id=?", session[:hotel_id])
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
    if !@bookings.blank? 
      csv_string = CSV.generate do |csv|
         csv << ["Booking_Number", "Total", "Arrival","Departure", "Booker_Name", "Night_Number", "Booking_Date"]
         @bookings.each do |book|
           csv << [book.id, book.price, book.from_date, book.to_date, book.traveler.blank? ? "" : book.traveler.name.titleize, book.night_number, book.created_at]
         end
      end   
     send_data csv_string,
     :type => 'text/csv; charset=iso-8859-1; header=present',
     :disposition => "attachment; filename=bookings.csv"
    else
      flash[:errors] = "There is no data"
      redirect_to bookings_path
    end
  end

  def export_in_excel
    @bookings = Booking.where(:hotel_id => session[:hotel_id])
    if !@bookings.blank? 
      csv_string = CSV.generate do |csv|
         csv << ["Booking_Number", "Total", "Arrival","Departure", "Booker_Name", "Night_Number", "Booking_Date"]
         @bookings.each do |book|
           csv << [book.id, book.price, book.from_date, book.to_date, book.traveler.blank? ? "" : book.traveler.name.titleize, book.night_number, book.created_at]
         end
      end   
     send_data csv_string,
     :type => 'text/xls; charset=iso-8859-1; header=present',
     :disposition => "attachment; filename=bookings.xls"
    else
      flash[:errors] = "There is no data"
      redirect_to bookings_path
    end
  end

  def overview
    @room_price = {}
    @bookings_array = []
    @booking_hash = {}
    @status_hash = {}
    @available_hash = {}
    @flag = 0
    @data = []
    @room_types = RoomType.all
    @room_sub_types = RoomSubType.where("hotel_id=? AND is_active = true", session[:hotel_id])
    if !params[:from_date].blank?
      @starting_date = params[:from_date].to_date
    else
      @starting_date = Date.today
    end
    @Bookings =  Booking.joins([:room => [:room_type => :room_availables]]).where("rooms.hotel_id = ?", session[:hotel_id]).select("room_availables.number, count(bookings.id) as booked, bookings.hotel_id, sum(bookings.adults) as adults, sum(bookings.children) as children, sum(bookings.price) as price, room_types.id as room_type_id, room_types.room_type as room_type,  bookings.from_date, bookings.to_date").group("room_types.id, bookings.from_date, bookings.to_date")
    @book_details = @Bookings.group_by(&:room_type_id)
    logger.info"******11**************#{@book_details.inspect}***********************"
    if !params[:from_date].blank? && !params[:to_date].blank?
      @range = (params[:to_date].to_date - params[:from_date].to_date).to_i + 1
    else
      @range = 15
    end
    @room_types.each do |type|
      @rates = RoomRate.where("room_type_id=? AND hotel_id=?",type.id, session[:hotel_id])
      @room_price.merge!(type.id => @rates)
    end
    @range.times do |day|
      @date = @starting_date.advance(:days => day)
      @book_details.each do |bookings|
        @booking_hash.merge!("#{bookings[0]}" => {}) unless @booking_hash.keys.include?("#{bookings[0]}")
        bookings[1].each do |booking|
          if(booking.from_date..booking.to_date).cover?(@date)
            if @booking_hash["#{bookings[0]}"].keys.include?(@date.to_s)
              @booking_hash["#{bookings[0]}"][@date.to_s] = booking.number + @booking_hash["#{bookings[0]}"][@date.to_s].to_i
            else
              @booking_hash["#{bookings[0]}"].merge!(@date.to_s => booking.number.to_i)
            end
          else
            @booking_hash["#{bookings[0]}"].merge!(@date.to_s => booking.number) unless @booking_hash["#{bookings[0]}"].keys.include?(@date.to_s)
          end
        end
      end
    end
    logger.info"(((((((((((((((((#{@booking_hash}((((((((((((((((((((((("
    @room_types.each do |type|
      @sub_types = RoomSubType.where("room_type_id=?",type.id)
      unless @sub_types.empty?
        @sub_types.each do |sub_type|
          @status_hash.merge!("#{sub_type.id}" => {})
          @statuses = RoomStatus.where("room_sub_type_id=? AND hotel_id=?", sub_type.id, session[:hotel_id])
          unless @statuses.empty?
            @statuses.each do |status|
              unless @booking_hash["#{type.id}"].blank?
                @booking_hash["#{type.id}"].each do |date|
                  if (status.from_date..status.to_date).cover?(date[0].to_date)
                    @flag = 1
                    if status.status == false
                      @room_number = 0
                      @availables = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", sub_type.id, session[:hotel_id])
                      unless @availables.blank?
                        @availables.each do |available|
                          if (available.from_date..available.to_date).cover?(date[0].to_date)
                            @room_number += available.number
                          end
                        end
                        if @room_number > 0
                          @status_hash["#{sub_type.id}"].merge!("#{date[0]}" => "bookable")
                        else
                          @status_hash["#{sub_type.id}"].merge!("#{date[0]}" => "none")
                        end
                      else
                        @status_hash["#{sub_type.id}"].merge!("#{date[0]}" => "none")
                      end
                    else
                      @status_hash["#{sub_type.id}"].merge!("#{date[0]}" => "closed")
                    end
                  end
                end
              else
                @range.times do |day|
                  if (status.from_date..status.to_date).cover?(@starting_date.advance(days: day))
                    if status.status == false
                      @room_number = 0
                      @availables = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", sub_type.id, session[:hotel_id])
                      unless @availables.blank?
                        @availables.each do |available|
                          if (available.from_date..available.to_date).cover?(@starting_date.advance(days: day))
                            @room_number += available.number
                          end
                        end
                        if @room_number > 0
                          @status_hash["#{sub_type.id}"].merge!("#{@starting_date.advance(days: day)}" => "bookable")
                        else
                          @status_hash["#{sub_type.id}"].merge!("#{@starting_date.advance(days: day)}" => "none")
                        end
                      else
                        @status_hash["#{sub_type.id}"].merge!("#{@starting_date.advance(days: day)}" => "none")
                      end
                    else
                      @status_hash["#{sub_type.id}"].merge!("#{@starting_date.advance(days: day)}" => "closed")
                    end
                  end
                end
              end
            end
            @range.times do |day|
              if !@status_hash["#{sub_type.id}"].keys.include?(@starting_date.advance(days: day).to_s)
                @status_hash["#{sub_type.id}"].merge!("#{@starting_date.advance(days: day)}" => "closed")
              end
            end
          else
            @range.times do |time|
              @date = @starting_date.advance(days: time)
              @status_hash["#{sub_type.id}"].merge!("#{@date}" => "closed")
            end
          end
        end
      end
    end
    logger.info"^^^^^^^^^^^^^#{@status_hash}^^^^^^^^^^^^^^^^^^^^^^^"
    @room_sub_types.each do |sub_type|
      @available_hash.merge!("#{sub_type.id}" => {})
      unless @booking_hash["#{sub_type.room_type_id}"].blank?
        @booking_hash["#{sub_type.room_type_id}"].each do |available|
          @rooms = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", sub_type.id, session[:hotel_id])
          unless @rooms.empty?
            @rooms.each do |room|
              if (room.from_date..room.to_date).cover?(available[0].to_date)
                @flag = 1
              end
              unless @flag == 0
                @available_hash["#{sub_type.id}"].merge!("#{available[0]}" => room.number)
                @flag = 0
              end
            end
            if @available_hash["#{sub_type.id}"]["#{available[0]}"].blank? && @flag == 0
              @available_hash["#{sub_type.id}"].merge!("#{available[0]}" => 0)
            end
          else
            @range.times do |time|
              @date = @starting_date.advance(days: time)
              @available_hash["#{sub_type.id}"].merge!("#{@date}" => 0)
            end
          end
        end
      else
        @range.times do |time|
          @date = @starting_date.advance(days: time)
          @rooms = RoomAvailable.where("room_sub_type_id=? AND hotel_id=?", sub_type.id, session[:hotel_id])
          unless @rooms.empty?
            @flag = 0
            @rooms.each do |room|
              if (room.from_date..room.to_date).cover?(@date)
                @available_hash["#{sub_type.id}"].merge!("#{@date}" => room.number)
                @flag = 1
              end
            end
            if @flag == 0
              @available_hash["#{sub_type.id}"].merge!("#{@date}" => 0)
            end
          else
            @available_hash["#{sub_type.id}"].merge!("#{@date}" => 0)
          end
        end
      end
      logger.info"^^^^^^^^^^^^^^^^#{@available_hash}^^^^^^^^^^^^2222"
    end    
  end

  def cancel_booking
    
  end

  def finance
    unless !session[:hotel_id].blank?
      session[:hotel_id] = params[:hotel_id]
    else
      session[:hotel_id] = session[:hotel_id]
    end
  end

  def invoice
    @hotel = Hotel.find_by_id(session[:hotel_id])
    @country = Carmen::Country.coded(@hotel.country_id)
    if !@country.blank? && @country.name == "Canada"
      @currency = "CAD"
    else
      @currency = "USD"
    end
    @total_price = Booking.where(:hotel_id => session[:hotel_id]).sum("price")
    @bookings = Booking.where(:hotel_id => session[:hotel_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    @bookings.each do |booking|
      if !@hotel.commission_rate.nil?
        @commission = (booking.price.to_i * (@hotel.commission_rate.amount).to_f) / 100
      else
        booking.price = booking.price.to_i
      end
    end
  end

  def status
    @booking = Booking.find_by_id(params[:id])
    @room = Room.find_by_id(@booking.room_id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "invoice_status"
      end
    end
  end

  def reserve_status
    @hotel = Hotel.find_by_id(session[:hotel_id])
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

  def booking_status
    @hotel = Hotel.find_by_id(session[:hotel_id])
    @booking = Booking.find_by_id(params[:id])
    @room = Room.find_by_id(@booking.room_id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "invoice_status"
      end
    end
  end

  def reservation_statements
    @hotel = Hotel.find_by_id(session[:hotel_id])
    @reserve_price = []
    if params[:from_date]
      @bookings = Booking.where("hotel_id=? AND from_date=?", session[:hotel_id], params[:from_date]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    else
      @bookings = Booking.where(:hotel_id => session[:hotel_id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    end

    @bookings.each do |booking|
      if !@hotel.commission_rate.nil?
        @reserve_price << (booking.price.to_i * (@hotel.commission_rate.amount).to_f) / 100
      else
        @reserve_price << 0
      end
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
    @hotel = Hotel.find_by_id(session[:hotel_id])
    @reserve_price = []
    @bookings.each do |booking|
      if !@hotel.commission_rate.nil?
        @reserve_price << (booking.price.to_i * (@hotel.commission_rate.amount).to_f) / 100
      else
        @reserve_price << 0
      end
    end
    if !@bookings.blank?
      csv_string = CSV.generate do |csv|
         csv << ["Booking_Number", "Booked_By", "Guest_Name","Checkin", "Checkout", "Room_Nights", "Commission", "Result", "Original_Amount", "Final_Amount", "Commission_Amount", "Remarks"]
         @bookings.each_with_index do |book,index|
            csv << [book.id, book.traveler.blank? ? "" : book.traveler.name, book.traveler.blank? ? "" : book.traveler.name, book.from_date, book.to_date, book.night_number, @hotel.commission_rate.blank? ? "" : @hotel.commission_rate.amount, "", book.price, @hotel.commission_rate.blank? ? book.price : (book.price.to_f + @reserve_price[index].to_f), @reserve_price[index], ""]
         end
      end   
     send_data csv_string,
     :type => 'text/csv; charset=iso-8859-1; header=present',
     :disposition => "attachment; filename=bookings.csv"
    else
      flash[:errors] = "There is no data"
      redirect_to reservation_statements_path
    end
  end

  def export_reservation_in_excel
    @bookings = Booking.where(:hotel_id => session[:hotel_id])
    @hotel = Hotel.find_by_id(session[:hotel_id])
    @reserve_price = []
    @bookings.each do |booking|
      if !@hotel.commission_rate.nil?
        @reserve_price << (booking.price.to_i * (@hotel.commission_rate.amount).to_f) / 100
      else
        @reserve_price << 0
      end
    end
    if !@bookings.blank?
      csv_string = CSV.generate do |csv|
         csv << ["Booking_Number", "Booked_By", "Guest_Name","Checkin", "Checkout", "Room_Nights", "Commission", "Result", "Original_Amount", "Final_Amount", "Commission_Amount", "Remarks"]
         @bookings.each_with_index do |book,index|
            csv << [book.id, book.traveler.blank? ? "" : book.traveler.name, book.traveler.blank? ? "" : book.traveler.name, book.from_date, book.to_date, book.night_number, @hotel.commission_rate.blank? ? "" : @hotel.commission_rate.amount, "", book.price, @hotel.commission_rate.blank? ? book.price : (book.price.to_f + @reserve_price[index].to_f), @reserve_price[index], ""]
         end
      end   
     send_data csv_string,
     :type => 'text/xls; charset=iso-8859-1; header=present',
     :disposition => "attachment; filename=bookings.xls"
    else
      flash[:errors] = "There is no data"
      redirect_to reservation_statements_path
    end
  end

  def download_reservation_data_month
    logger.info"&&&&&&&&&&&&#{cookies[:month]}&&&&&&&&&&&&&&&&&&&"
    @bookings = Booking.where("MONTH(created_at)=?",cookies[:month].to_i)
    if !@bookings.blank? 
      @bookings.each do |booking|
        @room = Room.find_by_id(booking.room_id)
        unless @room.blank? 
          booking.room_type = @room.room_type
          booking.save
        end 
      end
      respond_to do |format|
        format.html
        format.pdf do
          render :pdf => "monthly_invoice_status"
        end
      end
    else
      flash[:errors] = "There is no invoices in this month"
      redirect_to invoice_path
    end
  end

  def print_reservation_data_month
    @print_bookings = Booking.where("hotel_id=? AND MONTH(created_at)=?", session[:hotel_id], cookies[:month].to_i)
    @room_type = []
    @commissions = []
    @currency = @tot_comm = @tot_amount = 0
    @hotel = Hotel.find_by_id(@print_bookings.first.hotel_id)
    @country = Carmen::Country.coded(@hotel.country_id)
    if !@country.blank? && @country.name == "Canada"
      @currency = "CAD"
    else
      @currency = "USD"
    end
    unless @print_bookings.blank?
      @print_bookings.each do |booking|
        @room = Room.find_by_id(booking.room_id)
        unless @room.blank? 
          booking.room_type = @room.room_type
          booking.save
        end
        unless booking.room_type.blank?
          @room_type << booking.room_type.room_type
        else
          @room_type << ""
        end
        unless @hotel.commission_rate.blank?
          @commissions << (booking.price.to_f * (@hotel.commission_rate.amount.to_f).to_f) / 100
          @tot_comm += (booking.price.to_f * (@hotel.commission_rate.amount.to_f).to_f) / 100
        else
          @commissions << (booking.price.to_f * 12) / 100
          @tot_comm += (booking.price.to_f * 12) / 100
        end
        @tot_amount += booking.price.to_f
      end
    end
    @hotel_name = @print_bookings.first.hotel.name
    @hotel_addr = @print_bookings.first.hotel.address1
    @tot_comm = view_context.number_with_precision(@tot_comm, precision: 2, separator: '.')
    @tot_amount = view_context.number_with_precision(@tot_amount, precision: 2, separator: '.')
    @data = {"booking" => @print_bookings, "hotel_name" => @hotel_name, "hotel_address" => @hotel_addr, "room_type" => @room_type, "currency" => @currency, "commission" => @commissions, "tot_amount" => @tot_amount, "tot_comm" => @tot_comm}
    respond_to do |format|
      format.json { render json: @data }
    end
  end

  def download_statement_data_month
    @bookings = Booking.where("MONTH(created_at)=? AND hotel_id=?",cookies[:month_reserve].to_i,session[:hotel_id])
    @commission_rate = CommissionRate.first
    if !@bookings.blank?
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
    else
      flash[:errors] = "There is no invoices in this month"
      redirect_to reservation_statements_path
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
    @bookings_today = Booking.where("created_at >= ? AND hotel_id=?", Date.today, session[:hotel_id])
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

  def find_nights_this_week
    @bookings_today =  Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND hotel_id=?",session[:hotel_id])
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

  def find_nights_this_month
    @bookings_today =  Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND hotel_id=?", session[:hotel_id])
    @night = 0
    if !@bookings_today.nil?
      @bookings_today.each do |today|
        @night += (today.to_date - today.from_date).to_i
      end
    end
    return @night
  end

  def find_nights_this_year
    @bookings_today =  Booking.where("created_at > DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND hotel_id=?", session[:hotel_id])
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