class UsersController < ProjectsController
  def show
    @projects = Project.all
    @project = Project.new
  end

end
