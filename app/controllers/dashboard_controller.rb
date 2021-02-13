
require "mini_magick"

class DashboardController < ApplicationController

  # any line with 'if Interface.first.nil? redirect to root_url and return' ensures that the user is taken to the
  # homescreen and asked to create/customize an interface if it doesn't already exist (usually occurs with initial build)

# sets current user and interface
  def index
    @current_user = current_user
    if !Interface.first.nil?
      @interface = Interface.first
    end
  end

  def error404
    if Interface.first.nil?
      redirect_to root_url and return
    end
  end

  def error500
    if Interface.first.nil?
      redirect_to root_url and return
    end
  end

  def error403
    if Interface.first.nil?
      redirect_to root_url and return
    end
  end

  def customize_complete
    
    #sets custom interface settings: name, tagline, institution, color scheme
    interface = Interface.start_custom(params[:interface_name], params[:interface_tagline],
      params[:institution], params[:primary_color], params[:secondary_color], params[:accent_color], params[:user][:time_zone])

    #sets interface vectors and logos
    Interface.add_images(interface, params[:interface_vector], params[:interface_logo], params[:school_logo])

    #creates and sets landmarks with addresses for filter options
    Landmark.generate_landmarks(interface, params[:landmark_name1], params[:landmark_address1],
      params[:landmark_name2], params[:landmark_address2], params[:landmark_name3], params[:landmark_address3])

    #sets authentication credentials
    if params[:facebookauth]
      if !params[:facebook_client_id].blank? && !params[:facebook_client_secret].blank? && !params[:facebook_redirect].blank?
        fb = OAuthStrategy.create(name: "facebook", client_id: params[:facebook_client_id], client_secret: params[:facebook_client_secret], redirect_url: "#{params[:facebook_redirect]}/users/auth/facebook/callback")
        interface.o_auth_strategies << fb
      end
    end
    if params[:googleauth]
      if !params[:google_client_id].blank? && !params[:google_client_secret].blank? && !params[:google_redirect].blank?
        goog = OAuthStrategy.create(name: "google", client_id: params[:google_client_id], client_secret: params[:google_client_secret], redirect_url: "#{params[:google_redirect]}/users/auth/google_oauth2/callback")
        interface.o_auth_strategies << goog
      end
    end

    #creates new admin
    new_admin = OrgAdmin.initialize_admins(params[:institution], params[:admin_name], params[:admin_email])

    #shows temporary password
    if new_admin.save
      flash[:success] = "We have created an admin account for #{new_admin.name}! You have temporarily been given the password '#{new_admin.password}', so change it immediately from the login page."
    end

    interface.save
    #overwrites new colors
    File.atomic_write('/webapp/app/assets/stylesheets/set_color.scss') do |file|
      template = File.open('/webapp/app/assets/stylesheets/globalvars.txt')
      file.write(template.read + '$main-color: ' + Interface.first.primary_color + "; $secondary-color: " + Interface.first.secondary_color + "; $accent-color: " + Interface.first.accent_color + ";")
      template.close
    end
    #rails asset:compile
  end

  def create
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @user = User.find_or_create_from_auth_hash(auth_hash)
    selfcurrent_user = @user
    redirect_to '/'
  end

  # Render hours
  def hours
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @opportunities = Opportunity.joins(:users).where(users: { id:current_user.id})
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # Render notifications
  def notifs
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @notifications = Notification.where(recipient:current_user).reverse
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # Render volunteer history
  def history
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @user =current_user
    @opportunities = Opportunity.where(id: ArchivedOpportunity.joins(:users).where(
      users: { id:current_user.id}).pluck(:opportunity_id))
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # Filters opportunities within the distance from slider from user location
  def feed_volunteer
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @interface = Interface.first
    #var to determine navbar link colors
    @ifFeed = true

    check_auth

    #checks location to filter by
    if !params[:location].nil?
      $location = Landmark.first if params[:location] == "loc1"
      $location = Landmark.second if params[:location] == "loc2"
      $location = Landmark.third if params[:location] == "loc3"
    else
      $location = Landmark.first
    end

    #sets selected tags in mobile or standard view
    if params[:tags].nil?
      @tags = params[:mobile_tags]
    else
      @tags = params[:tags]
    end

    #gets selected distance radius from slider
    if params[:distance].nil?
      @slider = 15
    else
      @slider = params[:distance]
    end

    # Puts featured posts at the top ONLY if no filter has been applied
    if params[:page].nil?
      $opportunities = Opportunity.sorting_opps(!params[:upcoming].to_i.zero?,
        !params[:highrated].to_i.zero?, params[:freq], params[:remo], params[:distance],
        params[:location], @tags, false, nil).distinct
    end

    $opportunities = $opportunities.paginate(:page => params[:page], :per_page => 5)

    @organizations = Organization.all
    @opportunities = $opportunities

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit_user
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @address = current_user.address
    @tags = Tag.all
  end

  def update_user
    if Interface.first.nil?
      redirect_to root_url and return
    end

    if(update_params)
      redirect_to profile_volunteer_path
    else
      render 'edit_user'
    end
  end

  private def update_params
    if Interface.first.nil?
      redirect_to root_url and return
    end

    current_user.update(major: nil, school: nil, degree: nil, grad_year: nil, department: nil)

    # Updating user name, gender, phone, email, affiliation, and description
    current_user.update(name: params[:user][:name], gender: params[:gender], phone: params[:user][:phone],
      affiliation: params[:affiliation], description: params[:description].html_safe)

    # Updating address
    if current_user.address.nil?
      if !params[:address].nil?
        user_address = {}
        params[:address].each {|k,v| user_address[k]=v}
        current_user.build_address(user_address)
        current_user.save
      end
    else
      current_user.address.update(street: params[:user][:street], city: params[:user][:city],
        state: params[:user][:state], zip: params[:user][:zip])
    end

    # Updating major
    case current_user.affiliation
    when "Undergraduate student"
      if params[:user][:major].nil?
        current_user.update(major: params[:major], grad_year: params[:grad_year])
      else
        current_user.update(major: params[:user][:major], grad_year: params[:user][:grad_year])
      end
    when "Graduate/professional student"
      if params[:user][:school].nil?
        current_user.update(school: params[:school], grad_year: params[:grad_year])
      else
        current_user.update(school: params[:user][:school], grad_year: params[:user][:grad_year])
      end
    when "Alumni"
      if params[:user][:degree].nil?
        current_user.update(degree: params[:degree], grad_year: params[:grad_year])
      else
        current_user.update(degree: params[:user][:degree], grad_year: params[:user][:grad_year])
      end
    else
      if params[:user][:department].nil?
        current_user.update(department: params[:department])
      else
        current_user.update(department: params[:user][:department])
      end
    end

    # Updating tags
    current_user.tags.each do |n|
      current_user.tags.delete(n)
    end
    tags = params[:tags]
    if !tags.nil?
        tags.each do |tag|
            current_user.tags << Tag.where(name: tag)
        end
    end

    # Adding profile pic
    if params[:user][:profile_pic].nil?
      if !current_user.pictures.find_by_name("User#{current_user.id}pfp").nil?
        current_pfp =current_user.pictures.find_by_name("User#{current_user.id}pfp")
      current_user.pictures.delete(current_pfp)
        Picture.delete(current_pfp)
      end
      pfp = Picture.new(name: "User#{current_user.id}pfp", imageable_id:current_user.id,
        imageable_type: "#{current_user.class}")
      pfp.image = params[:user][:profile_pic]
      pfp.save!
      current_user.pictures << pfp
    end
  end

  def profile_volunteer
    if Interface.first.nil?
      redirect_to root_url and return
    end

    #Variable for determining navbar link colors
    @interface = Interface.first
    @ifDashboard = true
    check_auth
    current_user.opportunities.each do |opportunity|
      if (!opportunity.active || opportunity.ongoing) && params.has_key?(opportunity.id.to_s)
        #User can provide feedback
        if !params[:description].blank?
          feedback = Feedback.new(description:params[:description], anonymous:!params[:anonymous].nil?)
          feedback.organization = opportunity.organization
          feedback.user =current_user
          feedback.opportunity = opportunity
          feedback.save
          opportunity.organization.users.each do |user|
            Notification.create(recipient: user, actor:current_user, action:
              "has_submitted_feedback_for_your_organization", notifiable: feedback)
          end
        end
        #Archive opportunity
        if params[opportunity.id.to_s] == "confirm"
          archived = ArchivedOpportunity.new(title:opportunity.title,
          hours:params["hours"], organization:opportunity.organization.name)
          opportunity.archived_opportunities << archived
          current_user.archived_opportunities << archived
          if opportunity.ongoing == false
            archived.date = opportunity.date
            archived.save
            current_user.opportunities.delete(opportunity)
          else
            archived.date = opportunity.created_at
            archived.save
          end
        #delete opportunity
        elsif params[opportunity.id.to_s] == "deny"
          current_user.opportunities.delete(opportunity)
        end
      end
    end
    @opportunities = current_user.opportunities
  end

  def show
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @interface = Interface.first
    @user = User.find(params[:id])
  end

  protected

  def auth_hash
    if Interface.first.nil?
      redirect_to root_url and return
    end

    request.env['omniauth.auth']
  end
end
