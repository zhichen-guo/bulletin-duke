class OrganizationController < ApplicationController

    # any line with 'if Interface.first.nil? redirect to root_url and return' ensures that the user is taken to the
    # homescreen and asked to create/customize an interface if it doesn't already exist (usually occurs with initial build)

    before_action :check_auth

    def secret
        if Interface.first.nil?
            redirect_to root_url and return
        end
    end

    # Remove this method later
    def profile_organization
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @opportunities = Opportunity.all.org_opps(current_user)
        @organization = current_user.organization

        $weekly_stats = Hash.new
        for i in 0..4
            date = Date.today - Date.today.wday + (4 * (i - 4))
            week_hours = @organization.hours_during(date.to_time.to_i, (date + 7).to_time.to_i)
            $weekly_stats[date.strftime("%b %d") + " - " + (date + 6).strftime("%b %d")] = week_hours
        end

        $monthly_stats = Hash.new
        for i in 0..5
            date = 1.year.ago.at_beginning_of_month.to_time + i.month
            month_hours = @organization.hours_during(date.to_time.to_i, (date + 1.month).to_time.to_i)
            $monthly_stats[date.strftime("%b")] = month_hours
        end
    end

    def feed_organization
        if Interface.first.nil?
            redirect_to root_url and return
        end
        @interface = Interface.first

        #Var to determine navbar link colors
        @ifFeed = true
        unless current_user.is_a?(OrgAdmin) || current_user.admin == true
            redirect_to "/error403"
        end

        #checks location to filter by
    if !params[:location].nil?
        $location = Landmark.first if params[:location] == "loc1"
        $location = Landmark.second if params[:location] == "loc2"
        $location = Landmark.third if params[:location] == "loc3"
      else
        $location = Landmark.first
      end

        if params[:tags].nil?
            @tags = params[:mobile_tags]
        else
            @tags = params[:tags]
        end

        if params[:distance].nil?
            @slider = 15
        else
            @slider = params[:distance]
        end

        if params[:page].nil?
            $opportunities = Opportunity.sorting_opps(!params[:upcoming].to_i.zero?,
                !params[:highrated].to_i.zero?, params[:freq], params[:remo], params[:distance], 
                params[:location], @tags, true, current_user).distinct
        end

        $opportunities = $opportunities.paginate(:page => params[:page], :per_page => 5)
        @organizations = Organization.all
        @opportunities = $opportunities


        respond_to do |format|
            format.html
            format.js
        end
    end

    # Render notifications
    def notifications
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @notifications = Notification.where(recipient: current_user).reverse
        respond_to do |format|
            format.js {render layout: false}
        end
    end

    # Render stats
    def stats
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find_by_id(params[:id])
        respond_to do |format|
            format.js {render layout: false}
        end
    end

    # Render list of volunteers
    def volunteers
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find_by_id(params[:id])
        respond_to do |format|
            format.js {render layout: false}
        end
    end

    # Render history
    def histories
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find_by_id(params[:id])
        respond_to do |format|
            format.js {render layout: false}
        end
    end

    # Render opportunities
    def opps
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find_by_id(params[:id])
        respond_to do |format|
            format.js {render layout: false}
        end
    end

    # Render reviews
    def reviews
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find_by_id(params[:id])
        respond_to do |format|
            format.js {render layout: false}
        end
    end

    def new
        if Interface.first.nil?
            redirect_to root_url and return
        end
        @organization = Organization.new
    end

    def create
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.new(organization_params)
        @organization.save

        redirect_to @organization
    end

    # Liking system of organization
    def like
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find(params[:id])

        if !params[:like].nil? && !@organization.ratings.include?(Rating.find_by(user_id: current_user.id))
            if current_user.ratings.first.nil?
                rating = Rating.new(name:current_user.name)
                current_user.ratings << rating
            else
                rating = current_user.ratings.first
            end
            @organization.ratings << rating
        elsif !params[:like].nil?
            @organization.ratings.delete(Rating.find_by(user_id: current_user.id))
        end

        redirect_to @organization
    end

    def show
        @ifDashboard = true
        if Interface.first.nil?
            redirect_to root_url and return
        end
        @interface = Interface.first


        @organization = Organization.find(params[:id])

        $weekly_stats = Hash.new
        for i in 0..4
            date = Date.today - Date.today.wday + (4 * (i - 4))
            week_hours = @organization.hours_during(date.to_time.to_i, (date + 7).to_time.to_i)
            $weekly_stats[date.strftime("%b %d") + " - " + (date + 6).strftime("%b %d")] = week_hours
        end

        $monthly_stats = Hash.new
        for i in 0..5
            date = 1.year.ago.at_beginning_of_month.to_time + i.month
            month_hours = @organization.hours_during(date.to_time.to_i, (date + 1.month).to_time.to_i)
            $monthly_stats[date.strftime("%b")] = month_hours
        end

        respond_to do |format|
            format.html
            format.js
        end
    end

    def edit_custom
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = current_user.organization
    end

    def update
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find(params[:id])

        if(update_params)
            redirect_to @organization
        else
            render 'edit'
        end
    end

    def destroy
        if Interface.first.nil?
            redirect_to root_url and return
        end

        @organization = Organization.find(params[:id])
        @organization.destroy
        redirect_to organization_path
    end

    def approve
        if Interface.first.nil?
            redirect_to root_url and return
        end

      n = Notification.find_by(id: params[:notif])
      n.actor.update_attribute(:approved, true)
      UserMailer.approved_org_adm(n.actor.email, n.actor.organization.name).deliver_now
    end

    def deny
        if Interface.first.nil?
            redirect_to root_url and return
        end

      n = Notification.find_by(id: params[:notif])
      n.actor.update_attribute(:approved, false)
      UserMailer.denied_org_adm(n.actor.email, n.actor.organization.name).deliver_now
    end

    private def organization_params
        if Interface.first.nil?
            redirect_to root_url and return
        end

        params.require(:organization).permit(:name, :description, :location, :website, :email, :phone)
    end

    private def update_params
        if Interface.first.nil?
            redirect_to root_url and return
        end

        current_user.update(name: params[:org_admin][:username],
            position: params[:org_admin][:position], phone: params[:org_admin][:phone])

        if @organization.addresses.first.blank?
            if !params[:org_admin][:street].nil?
              @organization.addresses.build(street: params[:org_admin][:street],
                city: params[:org_admin][:city], state: params[:org_admin][:state], zip: params[:org_admin][:zip])
              @organization.save
            end
        else
            @organization.addresses.first.update(street: params[:org_admin][:street],
                city: params[:org_admin][:city], state: params[:org_admin][:state], zip: params[:org_admin][:zip])
        end

        @organization.update(name: params[:org_admin][:name], website: params[:org_admin][:website],
            phone: params[:org_admin][:org_phone], email: params[:org_admin][:email], description: params[:description],
            location: @organization.addresses.first.printable_address)

        #Adding profile pic
        if !params[:org_admin][:profile_pic].nil?
            if !@organization.pictures.nil? && !@organization.pictures.find_by_name("User#{@organization.id}pfp").nil?
                current_pfp = @organization.pictures.find_by_name("Org#{@organization.id}pfp")
                current_user.pictures.delete(current_pfp)
                Picture.delete(current_pfp)
            end
            pfp = Picture.new(name: "Org#{@organization.id}pfp", imageable_id: @organization.id,
                imageable_type: "#{@organization.class}")
            pfp.image = params[:org_admin][:profile_pic]
            pfp.save!
            @organization.pictures << pfp
        else
            true
        end
    end
end
