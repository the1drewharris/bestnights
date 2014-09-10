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
    @flag = 0
    unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:price].blank?
      if !params[:room_sub_type_id].blank?
        room_sub_type_rate(params[:room_sub_type_id],params[:days],params[:from_date],params[:to_date],params[:price],params[:room_id])
        @flag = 1
      elsif !params[:room_type_id].blank?
        room_type_rate(params[:room_id],params[:days],params[:from_date],params[:to_date],params[:price])
        @flag = 1
      end
      unless @flag == 0
        flash[:success] = 'Rate Was Successfully Updated For Sell.'
        redirect_to new_rate_path
      else
        flash[:errors] = "You need to select days and rooms."
        redirect_to new_rate_path
      end
    else
      flash[:errors] = 'You need to select days and rooms '
      redirect_to new_rate_path
    end
  end

  def copy_yearly_rates
    
  end

  def update_room_rates
    logger.info"**************#{params}*************************"
    unless (params[:room_sub_type_id].blank? || params[:room_id].blank?) && params[:price].blank?
      if !params[:room_sub_type_id].blank?
        logger.info"&&&&&&&&&&&&&&&"
        room_sub_type_rate_next_year(params[:room_sub_type_id],params[:days],params[:from_date],params[:to_date],params[:price],params[:room_id], params[:modify])
      elsif !params[:room_type_id].blank?
        room_type_rate_next_year(params[:room_id],params[:days],params[:from_date],params[:to_date],params[:price], params[:modify])
      end
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
              ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),@room_rate.price)
              end
              if (@room_rate.from_date..@room_rate.to_date).cover?(to_date.to_date)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_rate.to_date,@room_rate.price)
              end
              @room_rate.destroy
            else
              ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),params[:price].to_i)
              end
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
                  else
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: date),Date.today.advance(days: date),price)
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            ((to_date.to_date - from_date.to_date) + 1).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_rate.blank?
                  create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                else
                  if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date.advance(days: date))
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date,from_date.to_date.advance(days: date - 1),@room_rate.price)
                    create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
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
      room_id.each do |type|
        room_type_rate(type,days,from_date,to_date,price,room_sub_type_id)
      end
    end
  end

  def room_type_rate(room,days,from_date,to_date,price,room_sub_type_id)
    @sub_type = RoomSubType.find_by_room_type_id(room[0].to_s)
    if @sub_type.blank? || !room_sub_type_id.include?(room[0].to_s)
      @room_rate = RoomRate.find_by_room_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
      if days.blank?
        if @room_rate.blank?
          create_rate("",session[:hotel_id],room[0].to_s,from_date.to_date,to_date.to_date,price)
        else
          unless @room_rate.from_date == from_date.to_date && @room_rate.to_date == to_date.to_date
            if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date)
              create_rate("",session[:hotel_id],room[0].to_s,@room_rate.from_date,from_date.to_date.advance(:days => -1),@room_rate.price)
              create_rate("",session[:hotel_id],room[0].to_s,from_date.to_date,to_date.to_date,price)
              if (@room_rate.from_date..@room_rate.to_date).cover?(to_date.to_date)
                create_rate("",session[:hotel_id],room[0].to_s,to_date.to_date.advance(:days => 1),@room_rate.to_date,@room_rate.price)
              end
              @room_rate.destroy
            else
              create_rate("",session[:hotel_id],room[0].to_s,from_date.to_date,to_date.to_date,price)
            end
          else
            @room_rate.price = @room_rate.price
            @room_rate.save
          end
        end
      else
        if from_date.blank? && to_date.blank?
          days.each do |day|
            (((Date.today + 1.year) - (Date.today)) + 1).to_i.times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_rate.blank?
                  create_rate("",session[:hotel_id],room[0].to_s,Date.today.advance(days: date),Date.today.advance(days: date),price)
                else
                  if (@room_rate.from_date..@room_rate.to_date).cover?(Date.today.advance(days: date))
                    create_rate("",session[:hotel_id],room[0].to_s,@room_rate.from_date,Date.today.advance(days: date - 1),@room_rate.price)
                    create_rate("",session[:hotel_id],room[0].to_s,Date.today.advance(days: date),Date.today.advance(days: date),price)
                    @room_rate.destroy
                  else
                    create_rate("",session[:hotel_id],room[0].to_s,Date.today.advance(days: date),Date.today.advance(days: date),price)
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            ((to_date.to_date - from_date.to_date) + 1).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                if @room_rate.blank?
                  create_rate("",session[:hotel_id],room[0].to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                else
                  if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date.advance(days: date))
                    create_rate("",session[:hotel_id],room[0].to_s,@room_rate.from_date,from_date.to_date.advance(days: date - 1),@room_rate.price)
                    create_rate("",session[:hotel_id],room[0].to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
                    @room_rate.destroy
                  else
                    create_rate("",session[:hotel_id],room[0].to_s,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
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
    unless from_date > to_date
      @room_rates = RoomRate.where("from_date=? AND to_date=?", from_date, to_date)
      unless @room_rates.empty?
        @flag = 0
        @room_rates.each do |room_rate|
          logger.info"^^^^^^^^^^^#{room_rate.inspect}^^^^^^^^^^^^^^^^^^^^^^"
          if room_rate.room_type_id == room_type_id.to_i && room_rate.room_sub_type_id == room_sub_type_id.to_i && room_rate.hotel_id == hotel_id.to_i
            room_rate.price = price
            room_rate.save
            @flag = 1
          end
        end
        if @flag == 0
          @room_rate = RoomRate.new
          @room_rate.room_sub_type_id = room_sub_type_id
          @room_rate.hotel_id = hotel_id
          @room_rate.room_type_id = room_type_id
          @room_rate.from_date =from_date
          @room_rate.to_date = to_date
          @room_rate.price = price
          @room_rate.save
        end
      else
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
  end

  def room_sub_type_rate_next_year(room_sub_type_id,days,from_date,to_date,price,room_id,modify)
    room_sub_type_id.each do |room|
      @room_rate = RoomRate.find_by_room_sub_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
      @sub_type = RoomSubType.find_by_id(room[0].to_s)
      if days.blank?
        unless @room_rate.blank?
          if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date)
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if modify == "fix-increase"
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price)
              elsif modify == "fix-decrease"
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price)
              elsif modify == "percent-decrease"
                price = price - ((@room_rate.price * price.to_f) / 100)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),@room_rate.price)
              elsif modify == "percent-increase"
                price = price + ((@room_rate.price * price.to_f) / 100)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),@room_rate.price)
              else
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price.to_f)
              end
            end
            if (@room_rate.from_date..@room_rate.to_date).cover?(to_date.to_date)
              create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_rate.to_date,@room_rate.price)
            end
          else
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if modify == "fix-increase"
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price.to_f)
              elsif modify == "fix-decrease"
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price - price.to_f)
              elsif modify == "percent-decrease"
                price = price.to_f - ((@room_rate.price * price.to_f) / 100)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
              elsif modify == "percent-increase"
                price = price.to_f + ((@room_rate.price * price.to_f) / 100)
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
              else
                create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price.to_f)
              end
            end
          end
        end
      else
        if from_date.blank? && to_date.blank?
          days.each do |day|
            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                unless @room_rate.blank?
                  if (@room_rate.from_date..@room_rate.to_date).cover?(Date.today.advance(days: date))
                    if modify == "fix-increase"
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),@room_rate.price + price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),@room_rate.price + price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price + price.to_f)
                    elsif modify == "fix-decrease"
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),@room_rate.price -price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),@room_rate.price - price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price - price.to_f)
                    elsif modify == "percent-decrease"
                      price = price.to_f - ((@room_rate.price * price.to_f) / 100)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    elsif modify == "percent-increase"
                      price = price.to_f + ((@room_rate.price * price.to_f) / 100)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    else
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price.to_f)
                    end
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            ((to_date.to_date - from_date.to_date) + 1).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                unless @room_rate.blank?
                  if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date.advance(days: date))
                    if modify == "fix-increase"
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),@room_rate.price + price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price + price.to_f)
                    elsif modify == "fix-decrease"
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),@room_rate.price -price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price - price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price - price.to_f)
                    elsif modify == "percent-decrease"
                      price = price.to_f - ((@room_rate.price * price.to_f) / 100)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    elsif modify == "percent-increase"
                      price = price.to_f + ((@room_rate.price * price.to_f) / 100)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),price)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    else
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),price.to_f)
                      create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price.to_f)
                    end
                  end
                end
              end
            end
          end 
        end
      end
    end
    if room_id
      room_id.each do |type|
        room_type_rate_next_year(type,days,from_date,to_date,price,room_sub_type_id)
      end
    end
  end

  def room_type_rate_next_year(room_sub_type_id,days,from_date,to_date,price,room_id,modify)
    room_sub_type_id.each do |room|
      @room_rate = RoomRate.find_by_room_sub_type_id_and_hotel_id(room[0].to_s, session[:hotel_id])
      @sub_type = RoomSubType.find_by_id(room[0].to_s)
      if days.blank?
        unless @room_rate.blank?
          if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date)
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if modify == "fix-increase"
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price)
              elsif modify == "fix-decrease"
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price)
              elsif modify == "percent-decrease"
                price = price - ((@room_rate.price * price.to_f) / 100)
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),@room_rate.price)
              elsif modify == "percent-increase"
                price = price + ((@room_rate.price * price.to_f) / 100)
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),@room_rate.price)
              else
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price.to_f)
              end
            end
            if (@room_rate.from_date..@room_rate.to_date).cover?(to_date.to_date)
              create_rate(room[0].to_s,session[:hotel_id],@sub_type.room_type_id,to_date.to_date.advance(:days => 1),@room_rate.to_date,@room_rate.price)
            end
          else
            ((to_date.to_date - from_date.to_date).to_i + 1).times do |date|
              if modify == "fix-increase"
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price.to_f)
              elsif modify == "fix-decrease"
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price - price.to_f)
              elsif modify == "percent-decrease"
                price = price.to_f - ((@room_rate.price * price.to_f) / 100)
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
              elsif modify == "percent-increase"
                price = price.to_f + ((@room_rate.price * price.to_f) / 100)
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price)
              else
                create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: date),from_date.to_date.advance(days: date),price.to_f)
              end
            end
          end
        end
      else
        if from_date.blank? && to_date.blank?
          days.each do |day|
            ((Date.today + 1.year) - (Date.today)).to_i.times do |date|
              if Date.today.advance(days: date).strftime("%A").downcase == day[0].to_s
                unless @room_rate.blank?
                  if (@room_rate.from_date..@room_rate.to_date).cover?(Date.today.advance(days: date))
                    if modify == "fix-increase"
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),@room_rate.price + price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),@room_rate.price + price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price + price.to_f)
                    elsif modify == "fix-decrease"
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),@room_rate.price -price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),@room_rate.price - price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price - price.to_f)
                    elsif modify == "percent-decrease"
                      price = price.to_f - ((@room_rate.price * price.to_f) / 100)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    elsif modify == "percent-increase"
                      price = price.to_f + ((@room_rate.price * price.to_f) / 100)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    else
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),Date.today.advance(days: 1.year + (date - 1)),price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + date),Date.today.advance(days: 1.year + date),price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,Date.today.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price.to_f)
                    end
                  end
                end
              end
            end
          end
        else
          days.each do |day|
            ((to_date.to_date - from_date.to_date) + 1).to_i.times do |date|
              if from_date.to_date.advance(days: date).strftime("%A").downcase == day[0].to_s
                unless @room_rate.blank?
                  if (@room_rate.from_date..@room_rate.to_date).cover?(from_date.to_date.advance(days: date))
                    if modify == "fix-increase"
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),@room_rate.price + price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price + price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price + price.to_f)
                    elsif modify == "fix-decrease"
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),@room_rate.price -price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),@room_rate.price - price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),@room_rate.price - price.to_f)
                    elsif modify == "percent-decrease"
                      price = price.to_f - ((@room_rate.price * price.to_f) / 100)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    elsif modify == "percent-increase"
                      price = price.to_f + ((@room_rate.price * price.to_f) / 100)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),price)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price)
                    else
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,@room_rate.from_date.advance(days: 1.year),from_date.to_date.advance(days: 1.year + (date - 1)),price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + date),from_date.to_date.advance(days: 1.year + date),price.to_f)
                      create_rate("",session[:hotel_id],@sub_type.room_type_id,from_date.to_date.advance(days: 1.year + (date + 1)),@room_rate.to_date.advance(days: 1.year),price.to_f)
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

end
