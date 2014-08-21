class RoomSubTypesController < ApplicationController

  before_filter :authenticate_user!
  layout "admin_basic"
  # GET /room_sub_types
  # GET /room_sub_types.json
  def index
    @room_sub_types = RoomSubType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @room_sub_types }
    end
  end

  # GET /room_sub_types/1
  # GET /room_sub_types/1.json
  def show
    @room_sub_type = RoomSubType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @room_sub_type }
    end
  end

  # GET /room_sub_types/new
  # GET /room_sub_types/new.json
  def new
    @room_sub_type = RoomSubType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @room_sub_type }
    end
  end

  # GET /room_sub_types/1/edit
  def edit
    @room_sub_type = RoomSubType.find(params[:id])
  end

  # POST /room_sub_types
  # POST /room_sub_types.json
  def create
    @room_sub_type = RoomSubType.new(params[:room_sub_type])

    respond_to do |format|
      if @room_sub_type.save
        format.html { redirect_to room_sub_types_path, success: 'Room sub type was successfully created.' }
        format.json { render json: @room_sub_type, status: :created, location: @room_sub_type }
      else
        format.html { render action: "new" }
        format.json { render json: @room_sub_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /room_sub_types/1
  # PUT /room_sub_types/1.json
  def update
    @room_sub_type = RoomSubType.find(params[:id])

    respond_to do |format|
      if @room_sub_type.update_attributes(params[:room_sub_type])
        format.html { redirect_to @room_sub_type, success: 'Room sub type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @room_sub_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /room_sub_types/1
  # DELETE /room_sub_types/1.json
  def destroy
    @room_sub_type = RoomSubType.find(params[:id])
    @room_sub_type.destroy

    respond_to do |format|
      format.html { redirect_to room_sub_types_url }
      format.json { head :no_content }
    end
  end
end
