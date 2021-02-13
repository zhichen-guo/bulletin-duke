class UserMailer < ApplicationMailer
  default to: "mollyapsel@gmail.com",
          from: 'bulletin@duke.edu'

  def contact_all_volunteers(data,to,cc,bcc,subject)
    @body=data
    mail(to: to, cc: cc, bcc: bcc, subject: subject)
  end

  def approved_org(email, org)
    @org = org
    mail(to: email, subject: "Your organization has been approved")
  end

  def denied_org(email, org)
    @org = org
    mail(to: email, subject: "Your new organization request has been denied")
  end

  def approved_org_adm(email, org)
    @org = org
    mail(to: email, subject: "You have been approved as an admin for #{@org}")
  end

  def denied_org_adm(email, org)
    @org = org
    mail(to: email, subject: "Your request for admin access has been denied")
  end

  def signup_pending(to, opp)
    @opp = opp
    mail(to: to, subject: "Confirmation of sign up, pending approval")
  end

  def signup_confirm(to, opp)
    @opp = opp
    attachments['event.ics'] = create_event(to, opp).export()
    mail(to: to, subject: "Confirmation of sign up for #{@opp.title}")
  end

  def create_event(to, opp)
    address = opp.location.nil? ? "No Address" : opp.location
    url = "MAILTO:bulletin@duke.edu"
    options = {'CN' => '"' + opp.organization.name + '"'}
    organizer_property = RiCal::PropertyValue::CalAddress.new(nil,
                                                              :value => url,
                                                              :params => options)    
    event = RiCal.Event do
      summary	  opp.title
      description opp.description 
      dtstart     DateTime.parse(Opportunity.display_date_mailer(opp.date))
      dtend       DateTime.parse(Opportunity.display_date_mailer(opp.date + (opp.hours * 3600)))
      location    address
      add_attendee to
      organizer_property organizer_property
      alarm do
        description "Segment 51"
      end
    end
    event
  end

  def signup_approved(to, opp)
    @opp = opp
    mail(to: to, subject: "Sign-up for #{@opp.title} has been approved")
  end

  def signup_unapproved(to, opp)
    @opp = opp
    mail(to: to, subject: "Approval for #{@opp.title} has been removed")
  end

  def unsignup(to, opp)
    @opp = opp
    mail(to: to, subject: "Confirmation: sign-up cancelled")
  end

  def test_email
    emails = ["zg63@duke.edu", "mollyapsel@gmail.com", "joselyn.mcdonald@duke.edu", "danai.adkisson@duke.edu", "anna.mollard@duke.edu", "joshua.sauter@duke.edu"]
    mail(to: emails,  subject: "TESTING")
  end
end
