require "mini_magick"

class AdminController < ApplicationController
    
    # any line with 'if Interface.first.nil? redirect to root_url and return' ensures that the user is taken to the 
    # homescreen and asked to create/customize an interface if it doesn't already exist (usually occurs with initial build)

    before_action :check_auth, :check_admin
    def admin_home
        if Interface.first.nil?
            redirect_to root_url and return
        end

      @interface = Interface.first
        #var to determine navbar link colors
        @ifDashboard = true

        # Basic information on filled positions, available positions, upcoming opportuinities
        $positions_filled = Opportunity.where(active: 1).joins(:users).pluck("users.id").count
        $positions_available = Opportunity.where(active: 1).pluck(:volunteers_needed).sum - $positions_filled
        $opportunities_available = Opportunity.where(active: 1).count
        today = Date.today

        # Total hours logged by volunteers in the last 8 weeks for each week
        $weekly_stats = Opportunity.weekly_stats(today)

        # Total hours logged by volunteers in the last 12 months for each month
        $monthly_stats = Opportunity.monthly_stats(today)

        # Most popular tags based on the hours logged in the last week, month, and year
        $opptagsweek, $opptagsmonth, $opptagsyear = Opportunity.opp_tags(today)

        # Hours logged for each month, grouped by its tags (totals and percentages)
        $opp_tag_trend, $opp_tag_percs = Opportunity.opp_trends(today, $monthly_stats)
    end

    def admin_settings
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @interface = Interface.first
        @landmarks = [Interface.first.landmarks.first, Interface.first.landmarks.second, Interface.first.landmarks.third]
    end

    # @author Herleen Kaur
    # form that adds admins with the institution as their organization
    def update_admin
        if Interface.first.nil?
            redirect_to root_url and return
        end

        # Assigning other admins
        if params[:name] && params[:email]
            rand_password = ('0'..'z').to_a.shuffle.first(8).join
            new_admin = OrgAdmin.create(
                name:params[:name],
                email:params[:email],
                admin:true,
                password:rand_password,
                approved:true
            )
            new_admin.organization = Organization.find_by_name(Interface.first.institution)
            if new_admin.save
                flash[:success] = "We have created an admin account for #{new_admin.name}! They have temporarily been given the password '#{new_admin.password}', so have them change it immediately."
            else
                if params[:name].empty? || params[:email].empty?
                    flash[:error_message] = "Make sure all fields are filled out."
                elsif User.find_by_email(params[:email])
                    flash[:error_message] = "The email #{params[:email]} is already associated with an administrator."
                else
                    flash[:error_message] = "Something went wrong. Try again."
                end
            end
        end
        redirect_to '/admin_home'
    end

    # @author Herleen Kaur and Josh Sauter
    # form that updates the customizable interface
    # counterpart of this method is customize_complete in dashboard_controller
    def update_settings
        if Interface.first.nil?
            redirect_to root_url and return
        end

        interface = Interface.first

        if !params[:edit_interface_name].blank?
            interface.name = params[:edit_interface_name]
        else
            interface.name = 'The Bulletin'
        end
        if !params[:edit_interface_tagline].blank?
            interface.tag_line = params[:edit_interface_tagline]
        else
            interface.tag_line = 'An all-encompassing web platform connecting volunteers to their communities.'
        end
        interface.time_zone = params[:user][:time_zone]

        # changes interface's institution, but also changes the organization name that admins of this institution are associated with
        if !params[:institution].blank?
          oldinst = interface.institution
          interface.institution = params[:institution]
          Organization.find_by_name(oldinst).name = interface.institution
        end

        # updates color palette, or fills in with default color scheme if left blank
        if !params[:primary_color].blank?
            interface.primary_color = params[:primary_color]
        else
            interface.primary_color = '#132357'
        end
        if !params[:secondary_color].blank?
            interface.secondary_color = params[:secondary_color]
        else
            interface.secondary_color = '#0577B1'
        end
        if !params[:accent_color].blank?
            interface.accent_color = params[:accent_color]
        else
            interface.accent_color = '#B76D68'
        end

        # creates a picture for interface if it already exists, otherwise changes the image of the existing picture
        # for interface vector, interface logo, and school logo
        if (params[:edit_interface_vector])
            image = MiniMagick::Image.read(params[:edit_interface_vector])
            image.resize "698x459"
            if interface.pictures.first.nil?
                vector = Picture.new(name: "#{interface.id}vec", imageable_id: interface.id, imageable_type: "#{interface.class}")
                vector.image = image
                vector.save!
                interface.pictures << vector
            else
                vector = interface.pictures.first
                vector.image = image
                vector.save!
            end
        end
        if (params[:edit_interface_logo])
            image = MiniMagick::Image.read(params[:edit_interface_logo])
            image.resize "161x25"
            if interface.pictures.second.nil?
                logo = Picture.new(name: "#{interface.id}logo", imageable_id: interface.id, imageable_type: "#{interface.class}")
                logo.image = image
                logo.save!
                interface.pictures << logo
            else
                logo = interface.pictures.second
                logo.image = image
                logo.save!
            end
        end
        if (params[:edit_school_logo])
            if interface.pictures.third.nil?
                slogo = Picture.new(name: "#{interface.id}slogo", imageable_id: interface.id, imageable_type: "#{interface.class}")
                slogo.image = params[:edit_school_logo]
                slogo.save!
                interface.pictures << slogo
            else
                slogo = interface.pictures.third
                slogo.image = params[:edit_school_logo]
                slogo.save!
            end
        end

        if !params[:'0_name'].blank? && !params[:'0_street'].blank? && !params[:'0_city'].blank? && !params[:'0_state'].blank? && !params[:'0_zip'].blank?
            landmark = interface.landmarks.first
            address = landmark.address
            landmark.name = params[:'0_name']
            landmark.save
            address.street = params[:'0_street']
            address.city = params[:'0_city']
            address.state = params[:'0_state']
            address.zip = params[:'0_zip']
            address.save
        end

        # creates a landmark for interface if it already exists, otherwise changes the address of the existing landmark
        if !params[:'1_name'].blank? && !params[:'1_street'].blank? && !params[:'1_city'].blank? && !params[:'1_state'].blank? && !params[:'1_zip'].blank?
            if interface.landmarks.second.nil?
                landmark2 = Landmark.create(name: params[:'1_name'])
                address2 = Address.create(street: params[:'1_street'], city: params[:'1_city'], state: params[:'1_state'], zip: params[:'1_zip'])
                interface.landmarks << landmark2
                landmark2.address = address2
            else
                landmark = interface.landmarks.second
                address = landmark.address
                landmark.name = params[:'1_name']
                landmark.save
                address.street = params[:'1_street']
                address.city = params[:'1_city']
                address.state = params[:'1_state']
                address.zip = params[:'1_zip']
                address.save
            end
        end

        # creates a landmark for interface if it already exists, otherwise changes the address of the existing landmark
        if !params[:'2_name'].blank? && !params[:'2_street'].blank? && !params[:'2_city'].blank? && !params[:'2_state'].blank? && !params[:'2_zip'].blank?
            if interface.landmarks.third.nil?
                landmark3 = Landmark.create(name: params[:'2_name'])
                address3 = Address.create(street: params[:'2_street'], city: params[:'2_city'], state: params[:'2_state'], zip: params[:'2_zip'])
                interface.landmarks << landmark3
                landmark3.address = address3
            else
                landmark = interface.landmarks.third
                address = landmark.address
                landmark.name = params[:'2_name']
                landmark.save
                address.street = params[:'2_street']
                address.city = params[:'2_city']
                address.state = params[:'2_state']
                address.zip = params[:'2_zip']
                address.save
            end
        end

        # creates authentication for interface if it already exists, otherwise changes the inputs of the existing OAuthStrategy
        # for both Facebook and Google
        if params[:edit_facebookauth]
            if !params[:facebook_client_id].blank? && !params[:facebook_client_secret].blank? && !params[:facebook_redirect].blank? && !OAuthStrategy.find_by_name("facebook").nil?
                fb = OAuthStrategy.find_by_name("facebook")
                fb.client_id, fb.client_secret, fb.redirect_url = params[:facebook_client_id], params[:facebook_client_secret], params[:facebook_redirect]
                fb.save
            elsif !params[:facebook_client_id].blank? && !params[:facebook_client_secret].blank? && !params[:facebook_redirect].blank?
                fb = OAuthStrategy.create(name: "facebook", client_id: params[:facebook_client_id], client_secret: params[:facebook_client_secret], redirect_url: "#{params[:facebook_redirect]}/users/auth/facebook/callback")
                interface.o_auth_strategies << fb
            end
        else
            if !OAuthStrategy.find_by_name("facebook").nil?
                fb = OAuthStrategy.find_by_name("facebook")
                fb.delete
            end 
        end
        if params[:edit_googleauth]
            if !params[:google_client_id].blank? && !params[:google_client_secret].blank? && !params[:google_redirect].blank? && !OAuthStrategy.find_by_name("google").nil?
                goog = OAuthStrategy.find_by_name("google")
                goog.client_id, goog.client_secret, goog.redirect_url = params[:google_client_id], params[:google_client_secret], params[:google_redirect]
                goog.save
            elsif !params[:google_client_id].blank? && !params[:google_client_secret].blank? && !params[:google_redirect].blank?
                goog = OAuthStrategy.create(name: "google", client_id: params[:google_client_id], client_secret: params[:google_client_secret], redirect_url: "#{params[:google_redirect]}/users/auth/google_oauth2/callback")
                interface.o_auth_strategies << goog
            end
        else
            if !OAuthStrategy.find_by_name("google").nil?
                goog = OAuthStrategy.find_by_name("google")
                goog.delete
            end 
        end

        interface.save

        #overwrites new colors
        File.atomic_write('/webapp/app/assets/stylesheets/set_color.scss') do |file|
            template = File.open('/webapp/app/assets/stylesheets/globalvars.txt')
            file.write(template.read + '$main-color: ' + Interface.first.primary_color + "; $secondary-color: " + Interface.first.secondary_color + "; $accent-color: " + Interface.first.accent_color + ";")
            template.close
        end
        redirect_to '/admin_settings'
    end

    # Rendering statisitcs tab
    def statistics
        if Interface.first.nil?
            redirect_to root_url and return
        end

        respond_to do |format|
            format.html {
                render partial: 'stat'
            }
        end
    end

    # Rendering requests tab
    def requests
        if Interface.first.nil?
            redirect_to root_url and return
        end

      @notifications = Notification.where(recipient: current_user).reverse
        respond_to do |format|
            format.html {
                render partial: 'request'
            }
        end
    end

    # Rendering organizations list tab
    def organizations
        if Interface.first.nil?
            redirect_to root_url and return
        end

        respond_to do |format|
            format.html {
                render partial: 'organization'
            }
        end
    end

    def goals
        if Interface.first.nil?
            redirect_to root_url and return
        end

        respond_to do |format|
            format.html {
                render partial: 'goal'
            }
        end
    end


    # Send organization approval notification and email
    def approve
        if Interface.first.nil?
            redirect_to root_url and return
        end

      n = Notification.find_by(id: params[:notif])
      n.actor.organization.update_attribute(:approved, true)
      n.actor.update_attribute(:approved, true)
      UserMailer.approved_org(n.actor.email, n.actor.organization.name).deliver_now
    end

    # Send organization denial notification and email
    def deny
        if Interface.first.nil?
            redirect_to root_url and return
        end

      n = Notification.find_by(id: params[:notif])
      n.actor.update_attribute(:approved, false)
      UserMailer.approved_org(n.actor.email, n.actor.organization.name).deliver_now
    end
end
