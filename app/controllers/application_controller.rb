
class ApplicationController < ActionController::Base
    
    # any line with 'if Interface.first.nil? redirect to root_url and return' ensures that the user is taken to the 
    # homescreen and asked to create/customize an interface if it doesn't already exist (usually occurs with initial build)

    #checks if user has signed in
    def check_auth
        if Interface.first.nil?
            redirect_to root_url and return
        end

        if !user_signed_in?
            authenticate_user!
        end
    end

    #checks if user is an admin
    def check_admin
        if Interface.first.nil?
            redirect_to root_url and return
        end

        unless current_user.admin?
            redirect_to "/error403"
        end
    end

    #checks if user is an organization admin
    def check_org_admin
        if Interface.first.nil?
            redirect_to root_url and return
        end

        unless current_user.is_a? OrgAdmin
            redirect_to "/error403"
        end
    end

    protected

    # Return the path based on resource
    def after_sign_in_path_for(resource)
        if Interface.first.nil?
            redirect_to root_url and return
        end

        homepage = "/profile_volunteer"
        if current_user.sign_in_count == 1 && !current_user.admin?
            homepage = "/onboard"
        elsif current_user.admin?
            homepage = "/admin"
        elsif current_user.is_a? OrgAdmin
            homepage = current_user.organization
        end
        homepage
    end

    helper_method :which_feed

    # Determine which feed user will see based on user-type
    def which_feed
        if Interface.first.nil?
            redirect_to root_url and return
        end

        feed = "/feed_volunteer"
        if !current_user.admin? && current_user.type == "OrgAdmin"
            feed = "/feed_organization"
        end
        feed
    end

    helper_method :which_profile

    # Determine which profile user will see based on user-type
    def which_profile
        if Interface.first.nil?
            redirect_to root_url and return
        end

        if current_user.admin?
            "/admin"
        elsif current_user.is_a?(OrgAdmin)
            current_user.organization
        else
            "/profile_volunteer"
        end
    end

end
