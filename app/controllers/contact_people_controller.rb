class ContactPeopleController < ApplicationController
	before_filter :authenticate_user!, only: [:new, :create]  
  layout "admin_basic", only: [:new]
	def new
		@contacts = ContactPerson.all
		@contact = ContactPerson.new
		session[:hotel_id] = params[:hotel_id]
	end

	def create
		@contact = ContactPerson.new
		@contact.name = params[:name]
		@contact.title = params[:title]
		@contact.gender = params[:gender]
		@contact.address = params[:address]
		@contact.city = params[:city]
		@contact.email = params[:email]
		@contact.phone_number = params[:telephone_1]
		@contact.mobile_number = params[:telephone_2]
		@contact.postal_code = params[:zipcode]
		@contact.description = params[:description]
		@contact.designation = params[:contact_person][:name]
		@contact.country = params[:contact_person][:country]
		@contact.hotel_id = session[:hotel_id]
		@contact.fax = params[:fax]
		respond_to do |format|
      if @contact.save      	
        format.html { redirect_to new_contact_person_path, success: "New Contacts Successfully added" }
        format.json { render json: @contact, status: :created, location: @contact }
      else
        format.html { redirect_to new_contact_person_path, error: "Please Try again" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
	end
end
