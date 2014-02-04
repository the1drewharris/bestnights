class ManagerController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :ensure_manager!
  
  private
  def ensure_manager!
    su = current_user && current_user.manager?

    render 'public/404.html', :layout => false, :status => 404 unless su

    su
  end
end
