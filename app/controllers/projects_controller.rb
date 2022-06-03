class ProjectsController < ApplicationController

  def show()
    @project = Project.find_by(id: params[:project_id])
    if (@project)
      @posts = @project.posts.order()
    end
  end

  




