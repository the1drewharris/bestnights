class AdminMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def test
    mail(:subject => "Hi, this is bestnights", :to => "sheng.yang103@gmail.com")
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
  def new_hotel_request(users, hotel, manager)
    @manager = manager.email
    @hotel = hotel
    subject = "Request to activate new hotel"    
    users.each do |user|
      mail(:subject => subject, :to => user.email)
    end
  end
  
  ## when the admin changes the hotel
  def hotel_changed_notify(owner, hotel, admin)
    @admin = admin.email
    @hotel = hotel
    subject = "Room type changed"    
    
    mail(:subject => subject, :to => owner.email)
    
  end
  
  def registered_frontdesk_request(front_desk, hotel)
    @front_desk = front_desk.email
    @hotel = hotel
    subject = "Request to activate new front desk"
    mail(:subject => subject, :to => @hotel.user.email)
  end
end
