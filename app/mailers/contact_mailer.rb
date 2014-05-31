class ContactMailer < ActionMailer::Base
  default :from => "info@bestnights.com"
 
  def contact_email(email)
  	@email = email
    mail(:to => "info@bestnights.com",:from => @email, :subject => "New Contact Email")
  end
end
