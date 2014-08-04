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
		@days = []
		@rooms = []
		@available_days = []
		if !params[:room_id].blank? 
			params[:room_id].each do |room|
				@room = RoomAvailable.find_by_room_type_id_and_hotel_id(room[0],session[:hotel_id])
				if @room.nil?
					@room = RoomAvailable.new
				end
				@room.room_type_id = room[0]
				if params[:closed] == "0"
					# @room.number = 0
					@weekdays = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
					if !params[:days].blank?
						params[:days].each do |day|
							@weekdays.delete_at(@weekdays.index(day[0]))
						end
					end
					@weekdays.each do |day|
						@days << day
					end
				elsif params[:closed] == "1"
					# @room.number = 0
					if !params[:days].blank? 
						params[:days].each do |day|
							@days << day[0]
						end
					else
						@days = ""
					end
				elsif !params[:closed]
					if !params[:days].blank? 
						params[:days].each do |day|
							@available_days << day[0]
						end
					else
						@available_days = ""
					end
					@room.availables_days = @available_days
				end
				@room.days = @days
				if !params[:to_date].blank? 
					@room.to_date = DateTime.strptime(params[:to_date], '%m/%d/%Y').to_date
				else
					@room.to_date = ""
				end
				if !params[:from_date].blank? 
					@room.from_date = DateTime.strptime(params[:from_date], '%m/%d/%Y').to_date
				else
					@room.from_date = ""
				end
				if params[:rooms_to_sell]
					@room.number = params[:rooms_to_sell]
				end
				@room.hotel_id = session[:hotel_id]
      	@room.save
			end
		else
			@rooms = ""
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