class ContactsController < ApplicationController
	def new
    @contact = Contact.new
    @site_contact = SiteContact.first 
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact }
    end
  end

  # POST /trade_enqueries
  # POST /trade_enqueries.json
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save
      	ContactMailer.contact_email(@contact.email,params[:contact][:phone_number],params[:contact][:name]).deliver
        format.html { redirect_to new_contact_path, success: "Your Entry Has Been Submitted. Please Register Your Property!" }
        format.json { render json: @contact, status: :created, location: @contact }
      else
        format.html { render action: "new" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
end
