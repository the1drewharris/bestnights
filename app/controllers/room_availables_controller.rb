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
				@room = RoomAvailable.new
				@room.days = @days
				@room.room_type_id = room[0]
				@room.number = params[:rooms_to_sell]
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
				if !params[:days].blank? 
					params[:days].each do |day|
						@days << day[0]
					end
				else
					@days = ""
				end
      	@room.save
			end
		else
			@rooms = ""
		end
		respond_to do |format|
      format.html { redirect_to new_room_available_path, notice: 'room was successfully updated for sell.' }
      format.json { render json: @room, status: :created, location: @room }
    end
	end

	def edit
		@room = RoomAvailable.find(1)
	end

	def update_status
		@room = RoomAvailable.find(1)
		@room.update_attributes(:status => params["closed"])
		@room.save
		redirect_to rates_path
	end

end