class UsersController < ApplicationController
  def show
    if current_user.nil?
      redirect_to root_path
    end
    @projects = Project.all
    @project = Project.new
  end
end
