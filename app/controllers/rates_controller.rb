class RatesController < ApplicationController
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
    @rate = Rate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rate }
    end
  end

  # GET /rates/1/edit
  def edit
    @rate = Rate.find(params[:id])
  end

  # POST /rates
  # POST /rates.json
  def create
    logger.info"==================#{params}=================="
    @day = []
    @rooms = []
    @category = []
    if !params[:rate_cat_id].blank? 
      params[:days].each do |day|
        @day << day[0]
      end
    else
      @day = ""
    end

    if !params[:room_id].blank?
      params[:room_id].each do |room|
        @rooms << room[0]
      end
    else
      @rooms = ""
    end

    if !params[:rate_cat_id].blank?
      params[:rate_cat_id].each do |rate_category|
        @category << rate_category[0]
      end
    else 
      @category = ""
    end
    if !params[:from_date].blank? 
      @from_date = DateTime.strptime(params[:from_date], '%m/%d/%Y').to_date
    else
      @from_date = ""
    end

    if !params[:to_date].blank?
      @to_date = DateTime.strptime(params[:to_date], '%m/%d/%Y').to_date
    else
      @to_date = ""
    end
    @rate = Rate.new(to_date: @to_date, from_date: @from_date, price: params[:price], day: @day, room_id: @rooms, category: @category  )
    
    respond_to do |format|
      if @rate.save
        format.html { redirect_to new_rate_path, notice: 'rate was successfully updated for sell.' }
        format.json { render json: @rate, status: :created, location: @rate }
      else
        format.html { render action: "new", notice: 'Please fill all the information.' }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rates/1
  # PUT /rates/1.json
  def update
    @rate = Rate.find(params[:id])

    respond_to do |format|
      if @rate.update_attributes(params[:rate])
        format.html { redirect_to @rate, notice: 'Rate was successfully updated.' }
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
end
