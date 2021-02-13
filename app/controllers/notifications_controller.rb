class NotificationsController < ApplicationController

  # any line with 'if Interface.first.nil? redirect to root_url and return' ensures that the user is taken to the 
  # homescreen and asked to create/customize an interface if it doesn't already exist (usually occurs with initial build)

  before_action :authenticate_user!
  def index
    if Interface.first.nil?
      redirect_to root_url and return
    end
    #all of current user's unread notifications
    @notifications = Notification.where(recipient: current_user).unread
  end

  #marks notifications as read at given time
  def mark_as_read
    if Interface.first.nil?
      redirect_to root_url and return
    end

    @notifications = Notification.where(recipient: current_user).unread
    @notifications.update_all(read_at: Time.zone.now)
    render json: {success: true}
  end
end
