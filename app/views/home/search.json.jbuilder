json.array! @hotels do |hotel|
  json.id hotel.id
  json.name hotel.name
  json.description hotel.description
  json.lowest_price hotel.lowest_price
  json.city hotel.city
  json.state hotel.state.state_province
  
  stars = []
  hotel.star.to_i.times do
  	stars << { star: 1 }
	end
  json.stars stars
  
  room_attrs = []
  hotel.room_attributes.each do |room_attr|
  	room_attrs << { attr: room_attr.first }
	end  
  json.room_attributes room_attrs
						
	hotel_attrs = []
  hotel.hotel_attributes.each do |hotel_attr|
  	hotel_attrs << { attr: hotel_attr.attr }
	end
  json.hotel_attributes hotel_attrs
end