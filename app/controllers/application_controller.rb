class ApplicationController < ActionController::Base
  include SessionsHelper
  include InstagramAuthHelper

  before_action :check_logged_in

  def check_logged_in
    return if current_user
    return if '/projects/:id/invite'
    redirect_to root_path
  end

end
