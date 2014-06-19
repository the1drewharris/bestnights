# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140619065305) do

  create_table "agreements", :force => true do |t|
    t.integer  "hotel_id"
    t.string   "comission_rate"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "card_id"
  end

  create_table "availabilities", :force => true do |t|
    t.integer  "count"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "starting_inventory"
    t.date     "this_date"
    t.string   "room_id"
  end

  create_table "bed_types", :force => true do |t|
    t.string   "bedtype"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bookings", :force => true do |t|
    t.integer  "hotel_id"
    t.string   "price"
    t.date     "from_date"
    t.date     "to_date"
    t.integer  "adults"
    t.integer  "children"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "room_id"
    t.text     "message"
    t.string   "traveler_id"
    t.integer  "night_number"
  end

  create_table "cards", :force => true do |t|
    t.string   "card_type"
    t.string   "card_number"
    t.string   "ccid"
    t.datetime "expiration"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "country"
    t.string   "abbreviation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "default_messages", :force => true do |t|
    t.string   "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hotel_attribute_joins", :force => true do |t|
    t.integer  "hotel_id"
    t.integer  "hotel_attribute_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "hotel_attributes", :force => true do |t|
    t.string   "attr"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hotel_photos", :force => true do |t|
    t.integer  "hotel_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "hotels", :force => true do |t|
    t.integer  "state_id"
    t.string   "name"
    t.text     "description"
    t.string   "address1"
    t.string   "city"
    t.string   "zip"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "user_id"
    t.string   "country_id"
    t.string   "star"
    t.string   "status"
    t.string   "tax1"
    t.string   "tax2"
    t.string   "tax3"
    t.string   "tax4"
    t.decimal  "comission_rate", :precision => 10, :scale => 0
    t.integer  "card_id"
    t.string   "email_or_fax"
    t.string   "email"
    t.string   "fax"
    t.string   "tax1_label"
    t.string   "tax2_label"
    t.string   "tax3_label"
    t.string   "tax4_label"
  end

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], :name => "impressionable_type_message_index", :length => {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "messages", :force => true do |t|
    t.string   "message"
    t.string   "sender_id"
    t.string   "sender_type"
    t.string   "to_id"
    t.string   "to_type"
    t.string   "type"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "link"
    t.text     "content"
    t.string   "title"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "promotions", :force => true do |t|
    t.string   "coupon_code"
    t.datetime "expiry_date"
    t.datetime "start_date"
    t.integer  "transaction_item"
    t.string   "percent"
    t.decimal  "discount",         :precision => 10, :scale => 0
    t.integer  "times_allowed"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "hotel_id"
  end

  create_table "rate_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rates", :force => true do |t|
    t.string   "day"
    t.string   "category"
    t.integer  "hotel_id"
    t.date     "from_date"
    t.date     "to_date"
    t.string   "price"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "room_id"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "hotel_id"
    t.string   "review"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "reviewer_id"
  end

  create_table "room_attribute_joins", :force => true do |t|
    t.integer  "room_id"
    t.integer  "room_attribute_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "room_attributes", :force => true do |t|
    t.string   "attr"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "room_availables", :force => true do |t|
    t.integer  "room_id"
    t.string   "room_type_id"
    t.boolean  "status"
    t.date     "from_date"
    t.date     "to_date"
    t.string   "days"
    t.integer  "number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "room_photos", :force => true do |t|
    t.integer  "hotel_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "room_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "room_prices", :force => true do |t|
    t.integer  "hotel_id"
    t.integer  "room_type_id"
    t.string   "price"
    t.string   "additionaladultfee"
    t.string   "original_price"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "room_types", :force => true do |t|
    t.string   "room_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
  end

  create_table "rooms", :force => true do |t|
    t.integer  "hotel_id"
    t.integer  "room_type_id"
    t.string   "name"
    t.string   "description"
    t.string   "price"
    t.string   "additionaladultfee"
    t.string   "original_price"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "starting_inventory"
    t.integer  "bed_numbers"
    t.integer  "max_people"
    t.integer  "max_children"
    t.string   "room_size"
    t.string   "room_unit"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "states", :force => true do |t|
    t.integer  "country_id"
    t.string   "state_province"
    t.string   "abbreviation"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "traveler_payments", :force => true do |t|
    t.string   "transactionid"
    t.string   "amount"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "traveler_id"
  end

  create_table "travelers", :force => true do |t|
    t.string   "state_id"
    t.string   "country_id"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zip"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.string   "reset_password_sent_at"
    t.integer  "sign_in_count",          :default => 0, :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "role"
    t.integer  "terms_of_service"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "address1"
    t.string   "address2"
    t.string   "state_id"
    t.string   "country_id"
    t.string   "zip"
    t.string   "phone_number"
    t.string   "city"
    t.string   "status"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "hotel_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "venues", :force => true do |t|
    t.integer  "state_id"
    t.string   "name"
    t.string   "description"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zip"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
