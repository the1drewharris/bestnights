class TravelersController < ApplicationController
  #before_filter :authenticate_user!, only: [:new, :create]
  before_filter :authenticate_traveler!, only: [:booking_history, :edit_traveler, :change_password]  
  layout "admin_basic", only: [:index, :new, :edit, :show_traveler]
  layout "traveler_basic", only: [:booking_history, :edit_traveler, :show, :change_password]
  def index
    @travelers = Traveler.search(params[:search])
  end
  
  def show
      @traveler = Traveler.find(current_traveler)
  end

  def show_traveler
      @traveler = Traveler.find(params[:id])
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
      redirect_to traveler_path(@traveler.id)
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
    @traveler = Traveler.find(current_traveler.id)
  end
  
  def update
    traveler = Traveler.find(current_traveler.id)    
    if traveler.update_attributes(params[:traveler])
      flash[:success] = "Change Successful!"
      if session[:traveler_id]
        redirect_to traveler_path(traveler)
      else
        redirect_to travelers_path
      end 
    else
      flash[:errors] = traveler.errors.full_messages
      redirect_to request.referer
    end
  end
  
  def change_password
    @traveler = Traveler.find_by_id(current_traveler.id)
  end

  def destroy
    Traveler.find(params[:id]).destroy
    session[:room_type_id] = nil
    redirect_to travelers_path
  end

  def booking_history
    @booking_histories = Booking.where("traveler_id=?", current_traveler.id).paginate(:page => params[:page], :per_page => 20).order('id DESC')
  end

  def edit_traveler
    @traveler = Traveler.find(current_traveler.id)
    session[:traveler_id] = @traveler.id
  end

  def cancel_booking
    @booking = Booking.find_by_traveler_id_and_id(current_traveler.id,params[:book_id])
    if !@booking.nil?
      @hotel = Hotel.find(@booking.hotel_id)
      @traveler = Traveler.find_by_id(current_traveler.id)
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
      File.delete("#{Rails.root.to_s}/public/"+traveler.id.to_s+".txt")
    
      @fax_result = SOAP::WSDLDriverFactory.new("https://ws-sl.fax.tc/Outbound.asmx?WSDL").create_rpc_driver.SendCharFax("Username" => "bestnights","Password" => "@BestN1ghts","FileType" => "TXT","FaxNumber"=> "#{@hotel.fax}","Data" => "#{results[0]+"\n"+results[1]}")
      File.delete("#{Rails.root.to_s}/public/"+@traveler.id.to_s+".txt")
      unless @fax_result["SendCharFaxResult"].include? "-"
        # TravelerPayment.create(traveler_id: @traveler.id)
        redirect_to request.referer
      else
        flash[:notice] = "Hotel not canceled due wrong params"
        redirect_to request.referer
      end
    end
  end
end