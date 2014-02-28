class HotelSearch
  
  attr_accessor :params
  
  def initialize(params)
    @params = params || {}
  end
  
  def checkin
    params[:date][:checkin] if params[:date]    
  end
  
  def checkout
    params[:date][:checkout] if params[:date]
  end
  
  def stars
    params[:stars]
  end
  
  def features
    params[:features]
  end
  
  def prices
    params[:prices]
  end

  def search_name
    params[:search_name]
  end
    
  def room_type
    if params[:roomtype] == "1"
      "single"
    elsif params[:roomtype] == "2"
      "double"
    elsif params[:roomtype] == "3"
      "group"
    end
  end
  
  def room_numbers
    numbers = 0
    if room_type == 'single' or room_type == 'double'
      numbers = 1
    elsif room_type == 'group'
      numbers = params[:group][:roomqty].to_i
    end
    numbers
  end
  
  def bed_numbers_group
    arr = []
    if room_type == 'single'
      arr << 1
    elsif room_type == 'double'
      arr << 2
    elsif room_type == 'group'
      params[:group][:beds].each do |g|
        arr << g.last.values.collect{|s| s.to_i}.sum
      end
    end
    arr
  end
  
  def query
    params[:search]
  end
  
  def search
    available_hotels = []    
    ## search for city, state, zip
    hotels = Hotel.joins(:state).where('city LIKE ? Or zip = ? Or state_province LIKE ?', "%#{@search}%", "%#{@search}%", "%#{@search}%")
    
    hotels.each do |hotel|      
      if hotel.available?(checkin, checkout, room_numbers, bed_numbers_group)
        available_hotels << hotel
      end
    end
    
    available_hotels
  end
  
  def filter(hotels)
    filtered_hotels = []
    unless stars.nil?
      filtered_hotels = hotels.select { |h| stars.include?(h.star) }  
    end
    
    unless features.nil?
      filtered_hotels = hotels.select { |h| (features & h.hotel_attributes.collect{|ha| ha.id.to_s}) == features }  
    end
    
    unless prices.nil? 
      price_min = prices.first.to_f
      price_max = prices.last.to_f
      
      hotels.each do |hotel|
        if hotel.lowest_price >= price_min and hotel.lowest_price <= price_max
          filtered_hotels << hotel
        end 
      end
    end
    
    unless search_name.nil?
      filtered_hotels = hotels.select { |h| h.name.downcase.include?(search_name.downcase) }
    end
    
    filtered_hotels
  end
  
  
  
end