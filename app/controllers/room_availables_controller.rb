class RoomAvailablesController < ApplicationController
layout "admin_basic"
	def new
		@Rooms = Room.find_by_hotel_id(session[:hotel_id])
		if @Rooms.nil?
			flash[:success] = "Please Create Rooms First"
			redirect_to new_room_path
		else
			@room = RoomAvailable.new
			respond_to do |format|
	      format.html
	      format.json
			end
		end
	end

	def create
		unless params[:closed]
			params[:room_id].each do |room_type_id|
				@room = RoomAvailable.find_by_room_type_id_and_hotel_id(room_type_id[0],session[:hotel_id])
				if @room.blank?
					@room = RoomAvailable.new
					@room.room_type_id = room_type_id[0]
					@room.hotel_id = session[:hotel_id]
				end
				@room.from_date = DateTime.strptime(params[:from_date], '%m/%d/%Y')
				@room.to_date = DateTime.strptime(params[:to_date], '%m/%d/%Y')
				@room.number = params[:rooms_to_sell]
				@room.save
			end
		end
		respond_to do |format|
	  	flash[:success] = "Room was successfully updated for sell."
      format.html { redirect_to new_room_available_path }
      format.json { render json: @room, status: :created, location: @room }
    end
	end

	def edit
		@Rooms = Room.find_by_hotel_id(session[:hotel_id])
		if @Rooms.nil?
			flash[:success] = "Please Create Rooms First"
			redirect_to new_room_path
		else
			@room = RoomAvailable.all
			if @room.nil?
				flash[:success] = "Please set number of rooms to sell first"
				redirect_to new_room_available_path
			end
		end
	end

	def update_status
		@room = RoomAvailable.find(1)
		@room.update_attributes(:status => params["closed"])
		@room.save
		redirect_to rates_path
	end

end