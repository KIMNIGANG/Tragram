class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create
  before_action :store_location, only: :create

  def create
    if (user = User.find_or_create_from_auth_hash(auth_hash))
      log_in user
    end
    if session[:previous_url].present?
        print "ここからセッション"
        print session[:previous_url]
        redirect_to "projects/:id/invite"
    else
       redirect_to root_path
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
