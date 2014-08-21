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
		unless params[:room_sub_type_id].blank? || params[:rooms_to_sell].blank?
			params[:room_sub_type_id].each do |room_sub_type_id|
				@room = RoomAvailable.find_by_room_sub_type_id_and_hotel_id(room_sub_type_id[0],session[:hotel_id])
				@sub_type = RoomSubType.find_by_id(room_sub_type_id[0].to_s)
				if @room.blank?
					@room = RoomAvailable.new
					@room.room_sub_type_id = room_sub_type_id[0]
					@room.hotel_id = session[:hotel_id]
					@room.number = params[:rooms_to_sell]
					@room.room_type_id = @sub_type.room_type_id
					@room.from_date = params[:from_date].to_date
					@room.to_date = params[:to_date].to_date
					@room.save
				else
					unless @room.from_date == params[:from_date].to_date && @room.to_date == params[:to_date].to_date
						if (@room.from_date..@room.to_date).cover?(params[:from_date].to_date)
							@room_new_1 = RoomAvailable.new
							@room_new_2 = RoomAvailable.new

							@room_new_1.room_sub_type_id = room_sub_type_id[0]
							@room_new_1.hotel_id = session[:hotel_id]
							@room_new_1.number = @room.number
							@room_new_1.room_type_id = @sub_type.room_type_id
							@room_new_1.from_date = @room.from_date
							@room_new_1.to_date = params[:from_date].to_date.advance(:days => -1)

							@room_new_2.room_sub_type_id = room_sub_type_id[0]
							@room_new_2.hotel_id = session[:hotel_id]
							@room_new_2.number = params[:rooms_to_sell]
							@room_new_2.room_type_id = @sub_type.room_type_id
							@room_new_2.from_date = params[:from_date].to_date
							@room_new_2.to_date = params[:to_date].to_date

							@room_new_1.save
							@room_new_2.save

							if (@room.from_date..@room.to_date).cover?(params[:to_date].to_date)
								@room_new_3 = RoomAvailable.new
								@room_new_3.room_sub_type_id = room_sub_type_id[0]
								@room_new_3.hotel_id = session[:hotel_id]
								@room_new_3.number = @room.number
								@room_new_3.room_type_id = @sub_type.room_type_id
								@room_new_3.from_date = params[:to_date].to_date.advance(:days => 1)
								@room_new_3.to_date = @room.to_date
								@room_new_3.save
							end

							@room.destroy
						end
					else
						@room.number = params[:rooms_to_sell]
						@room.save
					end
				end
			end
			flash[:success] = "Room was successfully updated for sell."
			redirect_to new_room_available_path
		else
			flash[:errors] = 'You need to select days, category and number of rooms '
      redirect_to new_room_available_path
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
		logger.info"**********************#{params}***************************"
		unless params[:room_sub_type_id].blank?
			params[:room_sub_type_id].each do |room_sub_type_id|
				@status = RoomStatus.find_by_room_sub_type_id_and_hotel_id(room_sub_type_id[0].to_s,session[:hotel_id])
				@sub_type = RoomSubType.find_by_id(room_sub_type_id[0].to_s)
				if @status.blank?
					@status = RoomStatus.new
					@status.room_sub_type_id = room_sub_type_id[0]
					@status.hotel_id = session[:hotel_id]
					@status.room_type_id = @sub_type.room_type_id
					@status.from_date = params[:from_date].to_date
					@status.to_date = params[:to_date].to_date
					@status.status = params[:closed]
					@status.save
				else
					unless @status.from_date == params[:from_date].to_date && @status.to_date == params[:to_date].to_date
						if (@status.from_date..@status.to_date).cover?(params[:from_date].to_date)
							@status_new_1 = RoomStatus.new
							@status_new_2 = RoomStatus.new

							@status_new_1.room_sub_type_id = room_sub_type_id[0]
							@status_new_1.hotel_id = session[:hotel_id]
							@status_new_1.status = @status.status
							@status_new_1.room_type_id = @sub_type.room_type_id
							@status_new_1.from_date = @status.from_date
							@status_new_1.to_date = params[:from_date].to_date.advance(:days => -1)

							@status_new_2.room_sub_type_id = room_sub_type_id[0]
							@status_new_2.hotel_id = session[:hotel_id]
							@status_new_2.status = params[:closed]
							@status_new_2.room_type_id = @sub_type.room_type_id
							@status_new_2.from_date = params[:from_date].to_date
							@status_new_2.to_date = params[:to_date].to_date

							@status_new_1.save
							@status_new_2.save

							logger.info"^^^^^^^^^^^^^#{(@status.from_date..@status.to_date).cover?(params[:to_date].to_date)}^^^^^^^^^^^^^"
							if (@status.from_date..@status.to_date).cover?(params[:to_date].to_date)
								@status_new_3 = RoomStatus.new
								@status_new_3.room_sub_type_id = room_sub_type_id[0]
								@status_new_3.hotel_id = session[:hotel_id]
								@status_new_3.status = @status.status
								@status_new_3.room_type_id = @sub_type.room_type_id
								@status_new_3.from_date = params[:to_date].to_date.advance(:days => 1)
								@status_new_3.to_date = @status.to_date
								@status_new_3.save
							end

							@status.destroy
						end
					else
						@status.status = params[:closed]
						@status.save
					end
				end
			end
			flash[:success] = "Room Statuses have been changed"
			redirect_to room_availables_status_path
		else
			flash[:errors] = 'You need to select days, category and status '
      redirect_to room_availables_status_path
		end
	end

end