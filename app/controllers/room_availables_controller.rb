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
				@room.from_date = params[:from_date].to_date
				@room.to_date = params[:to_date].to_date
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

	def show
		@room_available = RoomAvailable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @room_available }
    end
	end

	def status
		@Rooms = Room.find_by_hotel_id(session[:hotel_id])
		if @Rooms.nil?
			flash[:success] = "Please Create Rooms First"
			redirect_to new_room_path
		else
			@room = RoomStatus.new
			respond_to do |format|
	      format.html
	      format.json
			end
		end
	end

	def update_status
		params[:room_id].each do |room|
			@status = RoomStatus.find_by_room_type_id_and_hotel_id(room[0].to_s,session[:hotel_id])
			if @status.blank?
				@status = RoomStatus.new
			end
			@status.room_type_id = room[0].to_s
			@status.hotel_id = session[:hotel_id]
			@status.from_date = params[:from_date].to_date
			@status.to_date = params[:to_date].to_date
			@status.status = params[:closed]
			@status.save
		end
	flash[:success] = "Room Statuses have been changed"
	redirect_to room_availables_status_path
	end

end