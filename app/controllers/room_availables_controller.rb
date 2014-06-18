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
		@room.to_date = params[:to_date]
		@room.from_date = params[:from_date]
		params[:days].each do |day|
			@days << day[0]
		end
		params[:room_id].each do |room|
			logger.info"****************#{room[0]}**********************"
			@rooms << room[0]
		end
		@room.days = @days
		@room.room_type_id = @rooms
		@room.number = params[:rooms_to_sell]
		respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'room was successfully updated for sell.' }
        format.json { render json: @room, status: :created, location: @room }
      else
        format.html { render action: "new" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
	end

end