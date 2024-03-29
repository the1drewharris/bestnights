class TravelersController < ApplicationController
  before_filter :authenticate_user!, only: [:index]
  layout :resolve_layout
  #before_filter :authenticate_traveler!, only: [:booking_history, :edit_traveler, :change_password]  

  def index
    @travelers = Traveler.search(params[:search])
  end
  
  def show
    unless current_traveler      
      unless session[:traveler_id]
        @traveler = Traveler.find(params[:id])
      else
        @traveler = Traveler.find_by_id(session[:traveler_id])
      end
    else
      @traveler = current_traveler
    end
    if @traveler.blank?
      redirect_to new_traveler_session_path
    end
      if session[:checkout_mode]
        redirect_to book_hotel_path(:traveler_id => @traveler.id)
      end
  end

  def show_traveler
    unless current_traveler
      @traveler = Traveler.find(session[:traveler_id])
    else
      @traveler = current_traveler
    end
      #@traveler = Traveler.find(params[:id])
  end
  
  def new
    @traveler = Traveler.new
  end
  
  def travelers_login
    
  end

  def traveler_login_create
   @traveler = Traveler.find_by_email(params[:email])
    session[:traveler] = @traveler
    if @traveler and @traveler.valid_password?(params[:password])
      session[:traveler_id] = @traveler.id
      unless session[:checkout_mode]
        redirect_to traveler_path(@traveler.id)
      else
        redirect_to book_hotel_path(:traveler_id => @traveler.id)
      end
    else
      flash[:success] = "Wrong Credential"
      redirect_to travelers_login_path
    end 
  end

  def create
    @traveler = Traveler.new(params[:traveler])
    if @traveler.save
      flash[:success] = "The traveler saved successfully!"
      redirect_to travelers_path
    else      
      flash[:errors] = @traveler.errors.full_messages
      render 'new'  
    end
  end
  
  def edit
    @traveler = Traveler.find(params[:id])
  end
  
  def update  
    if params[:id]
      traveler = Traveler.find(params[:id])
    elsif current_traveler
      traveler = Traveler.find(session[:traveler_id])
    else
      traveler = current_traveler
    end
    if traveler.update_attributes(params[:traveler])
      flash[:success] = "Change Successful!"
        redirect_to traveler_path(traveler)
    else
      flash[:errors] = traveler.errors.full_messages
      redirect_to request.referer
    end
  end
  
  def change_password
    unless current_traveler
      @traveler = Traveler.find(session[:traveler_id])
    else
      @traveler = current_traveler
    end
    #@traveler = Traveler.find_by_id(current_traveler.id)
  end

  def destroy
    Traveler.find(params[:id]).destroy
    session[:room_type_id] = nil
    session[:checkout_mode] = nil
    redirect_to travelers_path
  end

  def booking_history
    @booking_histories = Booking.where("traveler_id=?", params[:id]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
    @traveler = Traveler.find_by_id(params[:id])
  end

  def booking_status
    @booking = Booking.find_by_id(params[:id])
    @hotel = @booking.hotel
    @room = Room.find_by_id(@booking.room_id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "invoice_status"
      end
    end
  end

  def edit_traveler
    unless current_traveler
      @traveler = Traveler.find(session[:traveler_id])
    else
      @traveler = current_traveler
    end
    #@traveler = Traveler.find(current_traveler.id)
    session[:traveler_id] = @traveler.id
  end

  def cancel_booking
    @booking = Booking.find_by_traveler_id_and_id(current_traveler.id,params[:book_id])
    if !@booking.nil?
      @hotel = Hotel.find(@booking.hotel_id)
      unless current_traveler
      @traveler = Traveler.find(session[:traveler_id])
    else
      @traveler = current_traveler
    end
      @booking.is_cancel = true
      @booking.save
      FaxMailer.hotel_cancel_mail(@traveler,@hotel,@booking.id).deliver
      File.open("#{Rails.root.to_s}/public/"+@traveler.id.to_s+'.txt', 'wb') do|f|
        f.write('Traveler Name'+':'+@traveler.name+"\n"+'Traveler Email'+':'+@traveler.email)
      end
      results = []
      chars = 0
      File.open("#{Rails.root.to_s}/public/"+@traveler.id.to_s+'.txt', 'r').each { |line| results << line }
        results.each do |line|
        chars += line.length
      end
    
      @fax_result = SOAP::WSDLDriverFactory.new("https://ws-sl.fax.tc/Outbound.asmx?WSDL").create_rpc_driver.SendCharFax("Username" => "bestnights","Password" => "@BestN1ghts","FileType" => "TXT","FaxNumber"=> "#{@hotel.fax}","Data" => "#{results[0]+"\n"+results[1]}")
      
      unless @fax_result["SendCharFaxResult"].include? "-"
        # TravelerPayment.create(traveler_id: @traveler.id)
        redirect_to request.referer
      else
        flash[:notice] = "Hotel not canceled due wrong params"
        redirect_to request.referer
      end
    end
  end

  private 

  def resolve_layout
    case action_name
    when "index", "new", "edit", "show_traveler"
      "admin_basic"
    when "booking_history", "edit_traveler", "change_password"
      "traveler_basic"
    when "show"
      if current_traveler || session[:traveler_id]
        "traveler_basic"
      else
        "admin_basic"
      end
    else
      "application"
    end
  end
end