class UsersController < ApplicationController
  def show
    @projects = Project.all
    @project = Project.new
  end
end
