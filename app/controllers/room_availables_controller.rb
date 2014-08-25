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
		unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:rooms_to_sell].blank?
      unless params[:room_sub_type_id].blank?
        room_sub_type_sell(params[:room_sub_type_id],params[:days],params[:from_date],params[:to_date],params[:rooms_to_sell],params[:room_id])
      else
        room_type_sell(params[:room_id],params[:days],params[:from_date],params[:to_date],params[:rooms_to_sell])
      end
      flash[:success] = 'Room Was Successfully Updated For Sell.'
      redirect_to new_room_available_path
    else
      flash[:errors] = 'You need to select days, category and rooms '
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
		unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:closed].blank?
      unless params[:room_sub_type_id].blank?
        room_sub_type_status(params[:room_sub_type_id],params[:days],params[:from_date],params[:to_date],params[:closed],params[:room_id])
      else
        room_type_status(params[:room_id],params[:days],params[:from_date],params[:to_date],params[:closed])
      end
      flash[:success] = 'Room statuses have been changed.'
      redirect_to room_availables_status_path
    else
      flash[:errors] = 'You need to select days, category and rooms '
      redirect_to room_availables_status_path
    end
	end

	private

  def room_sub_type_sell(room_sub_type_id,days,from_date,to_date,rooms_to_sell,room_id)
    room_sub_type_id.each do |room|
      @room_sell = RoomAvailable.find_by_room_sub_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
      @sub_type = RoomSubType.find_by_id(room[0].to_s)
      if days.blank?
        if @room_sell.blank?
          create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
        else
          unless @room_sell.from_date == from_date.to_date && @room_sell.to_date == to_date.to_date
            if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date)
              create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,from_date.to_date.advance(:days => -1),@room_sell.rooms_to_sell)
              create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
              if (@room_sell.from_date..@room_sell.to_date).cover?(to_date.to_date)
                create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_sell.to_date,@room_sell.rooms_to_sell)
              end
              @room_sell.destroy
            else
              create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
            end
          else
            @room_sell.rooms_to_sell = @room_sell.rooms_to_sell
            @room_sell.save
          end
        end
      else
        if from_date.blank? && to_date.blank?
          days.each do |day|
            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_sell.blank?
                  create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
                else
                  if (@room_sell.from_date..@room_sell.to_date).cover?(Date.today.advance(days: date))
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,Date.today.advance(days: date - 1),@room_sell.rooms_to_sell)
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
                    @room_sell.destroy
                  else
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            (to_date.to_date - from_date.to_date).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_sell.blank?
                  create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                else
                  if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date.advance(days: date))
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,from_date.to_date.advance(days: date - 1),@room_sell.rooms_to_sell)
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                    @room_sell.destroy
                  else
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                  end
                end
              end
            end
          end
        end
      end
    end
    if room_id
      room_type_sell(room_id,days,from_date,to_date,rooms_to_sell)
    end
  end

  def room_type_sell(room_id,days,from_date,to_date,rooms_to_sell)
    room_id.each do |room|
    	@sub_type = RoomSubType.find_by_room_type_id(room[0].to_s)
      if @sub_type.blank? || !room_sub_type_id.include?(@sub_type.id.to_s)
	      @room_sell = RoomAvailable.find_by_room_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
	      if days.blank?
	        if @room_sell.blank?
	          create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
	        else
	          unless @room_sell.from_date == from_date.to_date && @room_sell.to_date == to_date.to_date
	            if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date)
	              create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,from_date.to_date.advance(:days => -1),@room_sell.rooms_to_sell)
	              create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
	              if (@room_sell.from_date..@room_sell.to_date).cover?(to_date.to_date)
	                create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_sell.to_date,@room_sell.rooms_to_sell)
	              end
	              @room_sell.destroy
	            else
	              create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
	            end
	          else
	            @room_sell.rooms_to_sell = @room_sell.rooms_to_sell
	            @room_sell.save
	          end
	        end
	      else
	        if from_date.blank? && to_date.blank?
	          days.each do |day|
	            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
	              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
	                if @room_sell.blank?
	                  create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
	                else
	                  if (@room_sell.from_date..@room_sell.to_date).cover?(Date.today.advance(days: date))
	                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,Date.today.advance(days: date - 1),@room_sell.rooms_to_sell)
	                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
	                    @room_sell.destroy
	                  else
	                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
	                  end
	                end
	              end
	            end
	          end
	        else
	          days.each do |day|
	            (to_date.to_date - from_date.to_date).to_i.times do |date|
	              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
	                if @room_sell.blank?
	                  create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
	                else
	                  if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date.advance(days: date))
	                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,from_date.to_date.advance(days: date - 1),@room_sell.rooms_to_sell)
	                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
	                    @room_sell.destroy
	                  else
	                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
	                  end
	                end
	              end
	            end
	          end
	        end
	      end
    	end
    end
  end

  def create_sell(room_sub_type_id,hotel_id,room_type_id,from_date,to_date,rooms_to_sell)
    @room_sell = RoomAvailable.new
    @room_sell.room_sub_type_id = room_sub_type_id
    @room_sell.hotel_id = hotel_id
    @room_sell.room_type_id = room_type_id
    @room_sell.from_date =from_date
    @room_sell.to_date = to_date
    @room_sell.number = rooms_to_sell
    @room_sell.save
  end

  def room_sub_type_status(room_sub_type_id,days,from_date,to_date,status,room_id)
    room_sub_type_id.each do |room|
      @room_status = RoomStatus.find_by_room_sub_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
      @sub_type = RoomSubType.find_by_id(room[0].to_s)
      if days.blank?
        if @room_status.blank?
          create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
        else
          unless @room_status.from_date == from_date.to_date && @room_status.to_date == to_date.to_date
            if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date)
              create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,from_date.to_date.advance(:days => -1),@room_status.status)
              create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
              if (@room_status.from_date..@room_status.to_date).cover?(to_date.to_date)
                create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_status.to_date,@room_status.status)
              end
              @room_status.destroy
            else
              create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
            end
          else
            @room_status.status = @room_status.status
            @room_status.save
          end
        end
      else
        if from_date.blank? && to_date.blank?
          days.each do |day|
            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_status.blank?
                  create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                else
                  if (@room_status.from_date..@room_status.to_date).cover?(Date.today.advance(days: date))
                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,Date.today.advance(days: date - 1),@room_status.status)
                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                    @room_status.destroy
                  else
                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            (to_date.to_date - from_date.to_date).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_status.blank?
                  create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                else
                  if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date.advance(days: date))
                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,from_date.to_date.advance(days: date - 1),@room_status.status)
                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                    @room_status.destroy
                  else
                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                  end
                end
              end
            end
          end
        end
      end
    end
    if room_id
      room_type_status(room_id,days,from_date,to_date,status,room_sub_type_id)
    end
  end

  def room_type_status(room_id,days,from_date,to_date,status,room_sub_type_id)
    room_id.each do |room|
    	@sub_type = RoomSubType.find_by_room_type_id(room[0].to_s)
      if @sub_type.blank? || !room_sub_type_id.include?(@sub_type.id.to_s)
	      @room_status = RoomStatus.find_by_room_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
	      if days.blank?
	        if @room_status.blank?
	          create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
	        else
	          unless @room_status.from_date == from_date.to_date && @room_status.to_date == to_date.to_date
	            if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date)
	              create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,from_date.to_date.advance(:days => -1),@room_status.status)
	              create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
	              if (@room_status.from_date..@room_status.to_date).cover?(to_date.to_date)
	                create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_status.to_date,@room_status.status)
	              end
	              @room_status.destroy
	            else
	              create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
	            end
	          else
	            @room_status.status = @room_status.status
	            @room_status.save
	          end
	        end
	      else
	        if from_date.blank? && to_date.blank?
	          days.each do |day|
	            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
	              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
	                if @room_status.blank?
	                  create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
	                else
	                  if (@room_status.from_date..@room_status.to_date).cover?(Date.today.advance(days: date))
	                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,Date.today.advance(days: date - 1),@room_status.status)
	                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
	                    @room_status.destroy
	                  else
	                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
	                  end
	                end
	              end
	            end
	          end
	        else
	          days.each do |day|
	            (to_date.to_date - from_date.to_date).to_i.times do |date|
	              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
	                if @room_status.blank?
	                  create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
	                else
	                  if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date.advance(days: date))
	                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,from_date.to_date.advance(days: date - 1),@room_status.status)
	                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
	                    @room_status.destroy
	                  else
	                    create_status(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
	                  end
	                end
	              end
	            end
	          end
	        end
	      end
    	end
    end
  end

  def create_status(room_sub_type_id,hotel_id,room_type_id,from_date,to_date,status)
    @room_status = RoomStatus.new
    @room_status.room_sub_type_id = room_sub_type_id
    @room_status.hotel_id = hotel_id
    @room_status.room_type_id = room_type_id
    @room_status.from_date =from_date
    @room_status.to_date = to_date
    @room_status.status = status
    @room_status.save
  end
  
end