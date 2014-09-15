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
    @flag = 0
		unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:rooms_to_sell].blank?
      if !params[:room_sub_type_id].blank?
        room_sub_type_sell(params[:room_sub_type_id],params[:days],params[:from_date],params[:to_date],params[:rooms_to_sell],params[:room_id])
        @flag = 1
      elsif !params[:room_id].blank?
        room_type_sell(params[:room_id],params[:days],params[:from_date],params[:to_date],params[:rooms_to_sell],params[:room_sub_type_id])
        @flag = 1
      end
      unless @flag == 0
        flash[:success] = 'Room Was Successfully Updated For Sell.'
        redirect_to new_room_available_path
      else
        flash[:errors] = 'You need to select days, category and rooms.'
        redirect_to new_room_available_path
      end
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
	      format.json{ render :json => @room }
			end
		end
	end

	def update_status
    @flag = 0
		unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:closed].blank?
      if !params[:room_sub_type_id].blank?
        @flag = 1
        params[:room_sub_type_id].each do |room|
          room_sub_type_status(room[0],params[:days],params[:from_date],params[:to_date],params[:closed],params[:room_id])
        end
      elsif !params[:room_id].blank?
        @flag = 1
        params[:room_id].each do |room|
          room_type_status(room[0].to_s,params[:days],params[:from_date],params[:to_date],params[:closed],params[:room_sub_type_id])
        end
      end
      unless @flag == 0
        flash[:success] = 'Room statuses have been changed.'
        redirect_to room_availables_status_path
      else
        flash[:errors] = 'You need to select days, category and rooms.'
        redirect_to room_availables_status_path
      end
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
      if days.blank? && !from_date.blank? && !to_date.blank?
        if @room_sell.blank?
          create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,rooms_to_sell)
        else
          unless @room_sell.from_date == from_date.to_date && @room_sell.to_date == to_date.to_date
            if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date)
              ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
                create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(:days => date),rooms_to_sell)
              end
              if (@room_sell.from_date..@room_sell.to_date).cover?(to_date.to_date)
                create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_sell.to_date,@room_sell.number)
              end
              #@room_sell.destroy
            else
              ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
                create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
              end
            end
          else
            @room_sell.number = @room_sell.number
            @room_sell.save
          end
        end
      else
        if from_date.blank? && to_date.blank? && !days.blank?
          days.each do |day|
            (((Date.today + 1.year) - (Date.today)).to_i + 1).times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_sell.blank?
                  create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
                else
                  if (@room_sell.from_date..@room_sell.to_date).cover?(Date.today.advance(days: date))
                    # (((Date.today + 1.year) - (Date.today)).to_i + 1).times do |date|
                    #   create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),@room_sell.number)
                    # end
                    logger.info"^^^^^^^^^^^^^^^^^^^^^^^^^^^^6"
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,Date.today.advance(days: date - 1),@room_sell.number)
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
                  else
                    #(((Date.today + 1.year) - (Date.today)).to_i + 1).times do |date|
                    logger.info"&&&&&&&&&&&&&&&&&&&7777777"
                      create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
                    #end
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_sell.blank?
                  create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                else
                  if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date.advance(days: date))
                    # ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
                    #   create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                    # end
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_sell.from_date,from_date.to_date.advance(days: date - 1),@room_sell.number)
                    create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                  else
                    #((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
                      create_sell(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
                    #end
                  end
                end
              end
            end
          end
        end
      end
    end
    if room_id
      room_type_sell(room_id,days,from_date,to_date,rooms_to_sell,room_sub_type_id)
    end
  end

  def room_type_sell(room_id,days,from_date,to_date,rooms_to_sell,room_sub_type_id)
    room_id.each do |room|
    	@sub_type = RoomSubType.find_by_room_type_id(room[0].to_s)
      if @sub_type.blank? || !room_sub_type_id.include?(@sub_type.id.to_s)
	      @room_sell = RoomAvailable.find_by_room_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
	      if days.blank? && !from_date.blank? && !to_date.blank?
	        if @room_sell.blank?
	          create_sell("",session[:hotel_id],room[0].to_s,from_date.to_date,to_date.to_date,rooms_to_sell)
	        else
	          unless @room_sell.from_date == from_date.to_date && @room_sell.to_date == to_date.to_date
	            if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date)
	              create_sell("",session[:hotel_id],room[0].to_s,@room_sell.from_date,from_date.to_date.advance(:days => -1),@room_sell.number)
	              create_sell("",session[:hotel_id],room[0].to_s,from_date.to_date,to_date.to_date,rooms_to_sell)
	              if (@room_sell.from_date..@room_sell.to_date).cover?(to_date.to_date)
	                create_sell("",session[:hotel_id],room[0].to_s,to_date.to_date.advance(:days => 1),@room_sell.to_date,@room_sell.number)
	              end
	              #@room_sell.destroy
	            else
	              create_sell("",session[:hotel_id],room[0].to_s,from_date.to_date,to_date.to_date,rooms_to_sell)
	            end
	          else
	            @room_sell.number = @room_sell.number
	            @room_sell.save
	          end
	        end
	      else
	        if from_date.blank? && to_date.blank?
	          days.each do |day|
	            (((Date.today + 1.year) - (Date.today)) + 1).to_i.times do |date|
	              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
	                if @room_sell.blank?
	                  create_sell("",session[:hotel_id],room[0].to_s,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
	                else
	                  if (@room_sell.from_date..@room_sell.to_date).cover?(Date.today.advance(days: date))
	                    create_sell("",session[:hotel_id],room[0].to_s,@room_sell.from_date,Date.today.advance(days: date - 1),@room_sell.number)
	                    create_sell("",session[:hotel_id],room[0].to_s,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
	                    @room_sell.destroy
	                  else
	                    create_sell("",session[:hotel_id],room[0].to_s,Date.today.advance(days: date),Date.today.advance(days: date),rooms_to_sell)
	                  end
	                end
	              end
	            end
	          end
	        else
	          days.each do |day|
	            ((to_date.to_date - from_date.to_date) + 1).to_i.times do |date|
	              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
	                if @room_sell.blank?
	                  create_sell("",session[:hotel_id],room[0].to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
	                else
	                  if (@room_sell.from_date..@room_sell.to_date).cover?(from_date.to_date.advance(days: date))
	                    create_sell("",session[:hotel_id],room[0].to_s,@room_sell.from_date,from_date.to_date.advance(days: date - 1),@room_sell.number)
	                    create_sell("",session[:hotel_id],room[0].to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
	                    @room_sell.destroy
	                  else
	                    create_sell("",session[:hotel_id],room[0].to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),rooms_to_sell)
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

  def room_sub_type_status(room_sub_type_id,days,from_date,to_date,status,room_id)
    @room_status = RoomStatus.find_by_room_sub_type_id_and_hotel_id(room_sub_type_id.to_s, session[:hotel_id])
    @sub_type = RoomSubType.find_by_id(room_sub_type_id.to_s)
    if days.blank?
      if @room_status.blank?
        create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
      else
        if @room_status.from_date != from_date.to_date && @room_status.to_date != to_date.to_date
          if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date)
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(:days => date),@room_status.status)
            end
            if (@room_status.from_date..@room_status.to_date).cover?(to_date.to_date)
              create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_status.to_date,@room_status.status)
            end
            @room_status.destroy
          else
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
            end
          end
        else
          @room_status.status = status
          @room_status.save
        end
      end
    else
      if from_date.blank? && to_date.blank?
        days.each do |day|
          ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
            if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
              if @room_status.blank?
                create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
              else
                if (@room_status.from_date..@room_status.to_date).cover?(Date.today.advance(days: date))
                  create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,Date.today.advance(days: date - 1),@room_status.status)
                  create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                else
                  create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                end
              end
            end
          end
        end
      else
        days.each do |day|
          ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
            if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
              if @room_status.blank?
                create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
              else
                if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date.advance(days: date))
                  create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,from_date.to_date.advance(days: date - 1),@room_status.status)
                  create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                else
                  create_status(room_sub_type_id.to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                end
              end
            end
          end
        end
      end
    end
    if room_id
      room_id.each do |type|
        room_type_status(type[0].to_s,days,from_date,to_date,status,room_sub_type_id)
      end
    end
  end

  def room_type_status(room_id,days,from_date,to_date,status,room_sub_type_id)
  	@sub_type = RoomSubType.find_by_room_type_id(room_id.to_s)
    @status = RoomStatus.find_by_room_type_id(room_id.to_s)
    if @sub_type.blank? && @status.blank?
      @room_status = RoomStatus.find_by_room_type_id_and_hotel_id(room_id.to_s, session[:hotel_id])
      if days.blank?
        if @room_status.blank?
          create_status("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
        else
          unless @room_status.from_date == from_date.to_date && @room_status.to_date == to_date.to_date
            if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date)
              create_status("",session[:hotel_id],@sub_type.room_type_id,@room_status.from_date,from_date.to_date.advance(:days => -1),@room_status.status)
              create_status("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
              if (@room_status.from_date..@room_status.to_date).cover?(to_date.to_date)
                create_status("",session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_status.to_date,@room_status.status)
              end
              @room_status.destroy
            else
              create_status("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,status)
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
                  create_status("",session[:hotel_id],room_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                else
                  if (@room_status.from_date..@room_status.to_date).cover?(Date.today.advance(days: date))
                    create_status("",session[:hotel_id],room_id,@room_status.from_date,Date.today.advance(days: date - 1),@room_status.status)
                    create_status("",session[:hotel_id],room_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                    @room_status.destroy
                  else
                    create_status("",session[:hotel_id],room_id,Date.today.advance(days: date),Date.today.advance(days: date),status)
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_status.blank?
                  create_status("",session[:hotel_id],room_id.to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                else
                  if (@room_status.from_date..@room_status.to_date).cover?(from_date.to_date.advance(days: date))
                    create_status("",session[:hotel_id],room_id.to_s,@room_status.from_date,from_date.to_date.advance(days: date - 1),@room_status.status)
                    create_status("",session[:hotel_id],room_id.to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
                    @room_status.destroy
                  else
                    create_status("",session[:hotel_id],room_id.to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),status)
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
    unless from_date > to_date
      @room_statuses = RoomStatus.where("from_date=? AND to_date=?", from_date, to_date)
      unless @room_statuses.empty?
        @flag = 0
        @room_statuses.each do |room|
          if room.room_type_id == room_type_id.to_i && room.room_sub_type_id == room_sub_type_id.to_i && room.hotel_id == hotel_id.to_i
            room.status = status
            room.save
            @flag = 1
          end
        end
        if @flag == 0
          @room = RoomStatus.new
          @room.room_sub_type_id = room_sub_type_id
          @room.hotel_id = hotel_id
          @room.room_type_id = room_type_id
          @room.from_date =from_date
          @room.to_date = to_date
          @room.status = status
          @room.save
        end
      else
        @room = RoomStatus.new
        @room.room_sub_type_id = room_sub_type_id
        @room.hotel_id = hotel_id
        @room.room_type_id = room_type_id
        @room.from_date =from_date
        @room.to_date = to_date
        @room.status = status
        @room.save
      end
    end
  end
  
end