class ApplicationController < ActionController::Base
  # protect_from_forgery 
  layout :layout_by_resource
  skip_before_filter :protect_from_forgery, :only => [:destroy]

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
