class AboutUsController < ApplicationController
  layout "admin_basic"
  before_filter :authenticate_user!
  # GET /about_us
  # GET /about_us.json
  def index
    @about_us = AboutU.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @about_us }
    end
  end

  # GET /about_us/1
  # GET /about_us/1.json
  def show
    @about_u = AboutU.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @about_u }
    end
  end

  # GET /about_us/new
  # GET /about_us/new.json
  def new
    @about_u = AboutU.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @about_u }
    end
  end

  # GET /about_us/1/edit
  def edit
    @about_u = AboutU.find(params[:id])
  end

  # POST /about_us
  # POST /about_us.json
  def create
    @about_u = AboutU.new(params[:about_u])

    respond_to do |format|
      if @about_u.save
        format.html { redirect_to @about_u, notice: 'About u was successfully created.' }
        format.json { render json: @about_u, status: :created, location: @about_u }
      else
        format.html { render action: "new" }
        format.json { render json: @about_u.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /about_us/1
  # PUT /about_us/1.json
  def update
    @about_u = AboutU.find(params[:id])

    respond_to do |format|
      if @about_u.update_attributes(params[:about_u])
        format.html { redirect_to @about_u, notice: 'About u was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @about_u.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /about_us/1
  # DELETE /about_us/1.json
  def destroy
    @about_u = AboutU.find(params[:id])
    @about_u.destroy

    respond_to do |format|
      format.html { redirect_to about_us_url }
      format.json { head :no_content }
    end
  end
end
