class ApplicationController < ActionController::Base
  include SessionsHelper
  #before_action :store_location
  before_action :check_logged_in

  def check_logged_in
    return if current_user
    return if '/projects/:id/invite'
    redirect_to root_path
  end

  #def store_location
    # store last url as long as it isn't a /users path
    #if (request.fullpath != "/")
    #  session[:previous_url] = request.referer
    #end
  #end

end