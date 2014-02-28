class ApplicationController < ActionController::Base
  # protect_from_forgery 
  skip_before_filter :protect_from_forgery, :only => [:destroy]

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      if resource.admin?
        hotels_url
      elsif resource.manager?
        resource.new_signup? ? new_hotel_url : hotels_url 
      elsif resource.front_desk?      
        hotels_url             
      end
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
end
