class SessionsController < Devise::SessionsController
  layout 'application'

  def destroy
    super
    reset_session
  end
end

