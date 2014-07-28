class RoomAvailablesController < ApplicationController
layout "admin_basic"
	def new
		@room = RoomAvailable.new
		respond_to do |format|
      format.html
      format.json
		end
	end

	def create
		@days = []
		@rooms = []
		if !params[:room_id].blank? 
			params[:room_id].each do |room|
				@room = RoomAvailable.find_by_room_type_id(room[0])
				if @room.nil?
					@room = RoomAvailable.new
				end
				@room.room_type_id = room[0]
				if params[:closed] == "0"
					@room.number = 0
					@weekdays = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
					if !params[:days].blank?
						params[:days].each do |day|
							@weekdays.delete_at(@weekdays.index(day[0]))
						end
					end
					@weekdays.each do |day|
						@days << day
					end
				elsif !params[:closed] || params[:closed] == "1"
					@room.number = 0
					if !params[:days].blank? 
						params[:days].each do |day|
							@days << day[0]
						end
					else
						@days = ""
					end
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
		@room = RoomAvailable.find(5)
	end

	def update_status
		@room = RoomAvailable.find(1)
		@room.update_attributes(:status => params["closed"])
		@room.save
		redirect_to rates_path
	end

end