class ApplicationController < ActionController::Base
  # protect_from_forgery 
  layout :layout_by_resource
  skip_before_filter :protect_from_forgery, :only => [:destroy]

  def create_sell(room_sub_type_id,hotel_id,room_type_id,from_date,to_date,rooms_to_sell)
    logger.info"&&&&&&&&&&&&&"
    @room = RoomAvailable.new
    @room.room_sub_type_id = room_sub_type_id
    @room.hotel_id = hotel_id
    @room.room_type_id = room_type_id
    @room.from_date =from_date
    @room.to_date = to_date
    @room.number = rooms_to_sell
    @room.save
  end

  protected 
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      if resource.admin?
        hotels_url
      elsif resource.manager?
        resource.new_signup? ? new_hotel_url : my_hotels_url 
      elsif resource.front_desk?      
        hotels_url             
      end
    elsif resource.is_a?(Traveler)
      traveler_detail_url
    else
      super
    end
  end
  
  def after_sign_out_path_for(resource)
    if resource.is_a?(User)
      root_url
    else
      super
    end
  end
  
  def layout_by_resource
    if devise_controller?
      "application"
    else
      "application"
    end
  end
end
