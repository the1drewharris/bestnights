class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all    
    elsif user.manager?
      can :manage, Hotel
      can :manage, Room
      can :manage, Promotion
      can :manage, Availability
      can :manage, HotelPhoto
      can :manage, RoomPhoto
    elsif user.front_desk?
      can [:read, :register], Hotel
    end 
  end
end
