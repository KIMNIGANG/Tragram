class UsersController < ApplicationController
  has_many :projects, through: :user_project

  def show
    #@projects = current_userの所属してるprojects全部
    @projects = users.projects
  end
end
