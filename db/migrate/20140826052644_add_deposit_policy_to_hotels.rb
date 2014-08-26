class AddDepositPolicyToHotels < ActiveRecord::Migration
  def change
  	add_column	:hotels, :cancellation_policy, :text
  	add_column	:hotels, :deposit_policy, :text
  	add_column	:hotels, :children_policy, :text
  	add_column	:hotels, :groups_policy, :text
  	add_column	:hotels, :internet_policy, :text
  	add_column	:hotels, :parking_policy, :text
  	add_column	:hotels, :pets_policy, :text
  end
end
