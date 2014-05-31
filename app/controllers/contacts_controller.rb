class ContactsController < ApplicationController
	def new
    @contact = Contact.new

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
      	ContactMailer.contact_email(@contact.email).deliver
        format.html { redirect_to new_contact_path, notice: t("form.thankyou_contact") }
        format.json { render json: @contact, status: :created, location: @contact }
      else
        format.html { render action: "new" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
end
