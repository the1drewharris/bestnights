class ApplicationController < ActionController::Base
  protect_from_forgery 
  
  def after_sign_in_path_for(resource)
    p "after admin signin"
    if resource.is_a?(User)
      if resource.admin?
        p "successfully admin signin "
        new_room_type_url
      elsif resource.manager?
        p "successfully manager signin "
        manager_url            
      end
    else
      super
    end
  end
  
  def after_sign_out_path_for(resource)
    p "after admin signout"
    if resource.is_a?(User)
      p "successfully user signout "
      root_url
    else
      super
    end
  end
  
end
