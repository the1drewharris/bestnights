class CommissionRatesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  layout "admin_basic", only: [:index, :new, :show, :edit]
  # GET /commission_rates
  # GET /commission_rates.json
  def index
    @commission_rates = CommissionRate.first

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @commission_rates }
    end
  end

  # GET /commission_rates/1
  # GET /commission_rates/1.json
  def show
    @commission_rate = CommissionRate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @commission_rate }
    end
  end

  # GET /commission_rates/new
  # GET /commission_rates/new.json
  def new
    @commission_rate = CommissionRate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @commission_rate }
    end
  end

  # GET /commission_rates/1/edit
  def edit
    @commission_rate = CommissionRate.find(params[:id])
  end

  # POST /commission_rates
  # POST /commission_rates.json
  def create
    @commission_rate = CommissionRate.new(params[:commission_rate])

    respond_to do |format|
      if @commission_rate.save
        format.html { redirect_to @commission_rate, notice: 'Commission rate was successfully created.' }
        format.json { render json: @commission_rate, status: :created, location: @commission_rate }
      else
        format.html { render action: "new" }
        format.json { render json: @commission_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /commission_rates/1
  # PUT /commission_rates/1.json
  def update
    @commission_rate = CommissionRate.find(params[:id])

    respond_to do |format|
      if @commission_rate.update_attributes(params[:commission_rate])
        format.html { redirect_to @commission_rate, notice: 'Commission rate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @commission_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commission_rates/1
  # DELETE /commission_rates/1.json
  def destroy
    @commission_rate = CommissionRate.find(params[:id])
    @commission_rate.destroy

    respond_to do |format|
      format.html { redirect_to commission_rates_url }
      format.json { head :no_content }
    end
  end
end
