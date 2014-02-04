class AdminController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :ensure_admin!
    
  private
  def ensure_admin!
    su = current_user && current_user.admin?

    render 'public/404.html', :layout => false, :status => 404 unless su

    su
  end
end
