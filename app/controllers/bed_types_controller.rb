class BedTypesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
  
  def new
    @bed_type = BedType.new
  end
  
  def create
    @bed_type = BedType.create(params[:bed_type])
    if @bed_type.save!
      flash[:success] = "The room type saved successfully!"
      redirect_to new_bed_type_path
    else
      redirect_to :back  
    end
  end
end