module HomeHelper
	def get_lowest_price(hotel_id,start_date,end_date)
		@prices = []
		@flag = 0
		@room_types = RoomType.all
		unless @room_types.blank?
			@room_types.each do |room_type|
				@room_sub_types = RoomSubType.where("room_type_id=?", room_type.id)
				unless @room_sub_types.blank?
					@room_sub_types.each do |room_sub_type|
						@rates = RoomRate.where("hotel_id=? AND room_sub_type_id=? AND room_type_id=?", hotel_id, room_sub_type.id, room_type.id).order("from_date")
						unless @rates.blank?
							@price = 0
							@rates.each do |rate|
								((end_date.to_date - start_date.to_date).to_i + 1).times do |day|
									if(rate.from_date..rate.to_date).cover?(start_date.to_date.advance(days: day))
										@price += rate.price
										@flag += 1
									end
								end
								if @flag == (end_date.to_date - start_date.to_date).to_i + 1
									if @price > 0
										@prices << @price
									end
									@price = 0
									@flag = 0
								end
							end
						end
					end
				end
			end
		end
		unless @prices.blank?
			return number_with_precision(@prices.min, :precision => 2, :separator => '.')
		else
			return 0.00
		end
	end
end
