class RoomAvailablesController < ApplicationController

	def new
		@room = RoomAvailable.new
		respond_to do |format|
      format.html
      format.json
		end
	end

	def create
		@room = RoomAvailable.new
		@days = []
		@rooms = []
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
		if !params[:room_id].blank? 
			params[:room_id].each do |room|
				@rooms << room[0]
			end
		else
			@rooms = ""
		end
		@room.days = @days
		@room.room_type_id = @rooms
		@room.number = params[:rooms_to_sell]
		respond_to do |format|
      if @room.save
        format.html { redirect_to new_room_available_path, notice: 'room was successfully updated for sell.' }
        format.json { render json: @room, status: :created, location: @room }
      else
        format.html { render action: "new" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
	end
end