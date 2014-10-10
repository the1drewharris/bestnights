class ContactMailer < ActionMailer::Base
  default :from => "info@bestnights.com"
 
  def contact_email(email, phone, name)
  	@email = email
  	@name = name
  	@phone = phone
    mail(:to => "info@bestnights.com",:from => @email, :subject => "New Contact Email")
  end
end
