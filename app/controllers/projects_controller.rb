class ProjectsController < ApplicationController
  def create
    project = Project.create(projects_params)
    project.save
    user_project = UserProject.create(user_id: @current_user.id, project_id: project.id)
    redirect_to controller: :users, action: :show, id: @current_user.id
  end

private

  def projects_params
    params.require(:project).permit(:name,:caption)
  end
end
