class AdminMailer < ActionMailer::Base
  default from: "info@bestnights.com"
  
  def test
    mail(:subject => "Hi, this is bestnights", :to => "the1drewharris@gmail.com")
  end
  
  ## when a hotel manager is added
  def new_hotel_manager(admins, manager)
    @manager = manager
    subject = "Request to activate new manager"
    admins.each do |admin|
      mail(:subject => subject, :to => admin.email)
    end
  end
  
  ## when the manager adds new room type
  def new_room_type_request(admins, room_type, manager)
    @manager = manager.email
    @room_type = room_type
    subject = "Request to activate new room type"    
    admins.each do |admin|
      mail(:subject => subject, :to => admin.email)
    end
  end
  
  ## when the admin changes the room type
  def room_type_changed_notify(managers, room_type, admin)
    @admin = admin.email
    @room_type = room_type
    subject = "Room type changed"    
    managers.each do |manager|
      mail(:subject => subject, :to => manager.email)
    end
  end
  
  ## when the manager adds new hotel
  def new_hotel_request(admins, hotel, manager)
    @manager = manager.email
    @hotel = hotel
    subject = "Request to activate new hotel"    
    admins.each do |admin|
      mail(:subject => subject, :to => admin.email)
    end
  end
  
  ## when the admin changes the hotel
  def hotel_changed_notify(owner, hotel, admin)
    @admin = admin.email
    @hotel = hotel
    subject = "Room type changed"    
    
    mail(:subject => subject, :to => owner.email)    
  end
  
  ## when the admin changes the user info
  def user_changed_notify(admin, user)
    @admin = admin.email
    @user = user
    subject = "User info has been changed"
    
    mail(:subject => subject, :to => user.email)
  end
  
  def registered_frontdesk_request(front_desk, hotel)
    @front_desk = front_desk.email
    @hotel = hotel
    subject = "Request to activate new front desk"
    mail(:subject => subject, :to => @hotel.user.email)
  end
  
  def added_hotel_request(user)
    subject = "Thank you for signing up for Best Nights!"
    mail(:subject => subject, :to => user.email)
  end
end
