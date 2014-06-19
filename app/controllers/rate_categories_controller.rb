class RateCategoriesController < ApplicationController
  # GET /rate_categories
  # GET /rate_categories.json
  def index
    @rate_categories = RateCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rate_categories }
    end
  end

  # GET /rate_categories/1
  # GET /rate_categories/1.json
  def show
    @rate_category = RateCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rate_category }
    end
  end

  # GET /rate_categories/new
  # GET /rate_categories/new.json
  def new
    @rate_category = RateCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rate_category }
    end
  end

  # GET /rate_categories/1/edit
  def edit
    @rate_category = RateCategory.find(params[:id])
  end

  # POST /rate_categories
  # POST /rate_categories.json
  def create
    @rate_category = RateCategory.new(params[:rate_category])

    respond_to do |format|
      if @rate_category.save
        format.html { redirect_to @rate_category, notice: 'Rate category was successfully created.' }
        format.json { render json: @rate_category, status: :created, location: @rate_category }
      else
        format.html { render action: "new" }
        format.json { render json: @rate_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rate_categories/1
  # PUT /rate_categories/1.json
  def update
    @rate_category = RateCategory.find(params[:id])

    respond_to do |format|
      if @rate_category.update_attributes(params[:rate_category])
        format.html { redirect_to @rate_category, notice: 'Rate category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rate_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rate_categories/1
  # DELETE /rate_categories/1.json
  def destroy
    @rate_category = RateCategory.find(params[:id])
    @rate_category.destroy

    respond_to do |format|
      format.html { redirect_to rate_categories_url }
      format.json { head :no_content }
    end
  end
end
