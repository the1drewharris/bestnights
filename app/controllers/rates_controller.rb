class RatesController < ApplicationController
  layout "admin_basic"
  # GET /rates
  # GET /rates.json
  def index
    @rates = Rate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rates }
    end
  end

  # GET /rates/1
  # GET /rates/1.json
  def show
    @rate = Rate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rate }
    end
  end

  # GET /rates/new
  # GET /rates/new.json
  def new
    @Rooms = Room.find_by_hotel_id(session[:hotel_id])
    if @Rooms.nil?
      flash[:success] = "Please Create Rooms First"
      redirect_to new_room_path
    else
      @rate = Rate.new
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @rate }
      end
    end
  end

  # GET /rates/1/edit
  def edit
    @rate = Rate.find(params[:id])
  end

  # POST /rates
  # POST /rates.json
  def create
    unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:price].blank?
      unless params[:room_sub_type_id].blank?
        room_sub_type_rate(params[:room_sub_type_id],params[:days],params[:from_date],params[:to_date],params[:price],params[:room_id])
      else
        room_type_rate(params[:room_id],params[:days],params[:from_date],params[:to_date],params[:price])
      end
      flash[:success] = 'Rate Was Successfully Updated For Sell.'
      redirect_to new_rate_path
    else
      flash[:errors] = 'You need to select days, category and rooms '
      redirect_to new_rate_path
    end
  end

  def copy_yearly_rates
    
  end

  def update_room_rates
    @rooms = RoomRate.all
    @rooms.each do |room|
      params[:days].each do |day|
        a = "rate_"
        if params[:modify] == "fix-increase"
          f = a + day[0]
          query = (eval "room." + f).to_f + params[:price].to_f
          params[:room_id].each do |room|
            ActiveRecord::Base.connection.execute("UPDATE room_rates SET " + f.to_s + "=" + query.to_s + "WHERE room_type_id = " + room[0].to_s)
          end
        elsif params[:modify] == "fix-decrease"
          f = a + day[0]
          query = (eval "room." + f).to_f - params[:price].to_f
          params[:room_id].each do |room|
            ActiveRecord::Base.connection.execute("UPDATE room_rates SET " + f.to_s + "=" + query.to_s + "WHERE room_type_id = " + room[0].to_s)
          end
        elsif params[:modify] == "percent-decrease"
          f =a + day[0]
          query = (eval "room." + f).to_f - ((params[:price].to_f * (eval "room." + f).to_f)/100)
          params[:room_id].each do |room|
            ActiveRecord::Base.connection.execute("UPDATE room_rates SET " + f.to_s + "=" + query.to_s + "WHERE room_type_id = " + room[0].to_s)
          end
        elsif params[:modify] == "percent-increase"
          f =a + day[0]
          query = (eval "room." + f).to_f + ((params[:price].to_f * (eval "room." + f).to_f)/100)
          params[:room_id].each do |room|
            ActiveRecord::Base.connection.execute("UPDATE room_rates SET " + f.to_s + "=" + query.to_s + "WHERE room_type_id = " + room[0].to_s)
          end
        else
          f =a + day[0]
          params[:room_id].each do |room|
            ActiveRecord::Base.connection.execute("UPDATE room_rates SET " + f.to_s + "=" + params[:price].to_s + "WHERE room_type_id =" + room[0].to_s)
          end
        end
      end
      room.save
    end
    redirect_to copy_yearly_rates_path
  end

  # PUT /rates/1
  # PUT /rates/1.json
  def update
    @rate = Rate.find(params[:id])

    respond_to do |format|
      if @rate.update_attributes(params[:rate])
        flash[:success] = "Rate was successfully updated."
        format.html { redirect_to @rate }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rates/1
  # DELETE /rates/1.json
  def destroy
    @rate = Rate.find(params[:id])
    @rate.destroy

    respond_to do |format|
      format.html { redirect_to rates_url }
      format.json { head :no_content }
    end
  end

  def search
    @rate = RoomRate.find_by_room_type_id_and_hotel_id(params[:room_type_id],session[:hotel_id])
    respond_to do |format|
      format.json { render json: @rate }
    end
  end

  private

  def room_sub_type_rate(room_sub_type_id,days,from_date,to_date,price,room_id)
    room_sub_type_id.each do |room|
      @room_rate = RoomRate.find_by_room_sub_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
      @sub_type = RoomSubType.find_by_id(room[0].to_s)
      if days.blank?
        if @room_rate.blank?
          create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,price)
        else
          unless @room_rate.from_date == from_date.to_date && @room_rate.to_date == to_date.to_date
            if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date)
              create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,from_date.to_date.advance(:days => -1),@room_rate.price)
              create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,price)
              if (@room_rate.from_date..@room_rate.to_date).cover?(to_date.to_date)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_rate.to_date,@room_rate.price)
              end
              @room_rate.destroy
            else
              create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,price)
            end
          else
            @room_rate.price = @room_rate.price
            @room_rate.save
          end
        end
      else
        if from_date.blank? && to_date.blank?
          days.each do |day|
            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_rate.blank?
                  create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                else
                  if (@room_rate.from_date..@room_rate.to_date).cover?(Date.today.advance(days: date))
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,Date.today.advance(days: date - 1),@room_rate.price)
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                    @room_rate.destroy
                  else
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            (to_date.to_date - from_date.to_date).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_rate.blank?
                  create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                else
                  if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date.advance(days: date))
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,from_date.to_date.advance(days: date - 1),@room_rate.price)
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                    @room_rate.destroy
                  else
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                  end
                end
              end
            end
          end
        end
      end
    end
    if room_id
      @room = RoomSubType.find_by_room_type_id(room[0].to_s)
      if @room.blank? || !params[:room_sub_type_id].include?(@room.id.to_s)
        room_type_rate(room_id,days,from_date,to_date,price,room_sub_type_id)
      end
    end
  end

  def room_type_rate(room_id,days,from_date,to_date,price,room_sub_type_id)
    room_id.each do |room|
      @sub_type = RoomSubType.find_by_room_type_id(room[0].to_s)
      if @sub_type.blank? || !room_sub_type_id.include?(@room.id.to_s)
        @room_rate = RoomRate.find_by_room_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
        if days.blank?
          if @room_rate.blank?
            create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,price)
          else
            unless @room_rate.from_date == from_date.to_date && @room_rate.to_date == to_date.to_date
              if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,from_date.to_date.advance(:days => -1),@room_rate.price)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,price)
                if (@room_rate.from_date..@room_rate.to_date).cover?(to_date.to_date)
                  create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_rate.to_date,@room_rate.price)
                end
                @room_rate.destroy
              else
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date,to_date.to_date,price)
              end
            else
              @room_rate.price = @room_rate.price
              @room_rate.save
            end
          end
        else
          if from_date.blank? && to_date.blank?
            days.each do |day|
              ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
                if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                  if @room_rate.blank?
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                  else
                    if (@room_rate.from_date..@room_rate.to_date).cover?(Date.today.advance(days: date))
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,Date.today.advance(days: date - 1),@room_rate.price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                      @room_rate.destroy
                    else
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                    end
                  end
                end
              end
            end
          else
            days.each do |day|
              (to_date.to_date - from_date.to_date).to_i.times do |date|
                if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                  if @room_rate.blank?
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                  else
                    if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date.advance(days: date))
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,from_date.to_date.advance(days: date - 1),@room_rate.price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                      @room_rate.destroy
                    else
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
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

  def create_rate(room_sub_type_id,hotel_id,room_type_id,from_date,to_date,price)
    @room_rate = RoomRate.new
    @room_rate.room_sub_type_id = room_sub_type_id
    @room_rate.hotel_id = hotel_id
    @room_rate.room_type_id = room_type_id
    @room_rate.from_date =from_date
    @room_rate.to_date = to_date
    @room_rate.price = price
    @room_rate.save
  end
end
