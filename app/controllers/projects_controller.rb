class ProjectsController < ApplicationControll
  require 'rack'

  before_action(only: %i[show_posts destroy edit]){project = Project.find_by(id: params[:project_id])}

#  def create()
    # query = ?members=[id=hoge,id=foo,id=bar]
    #members = params[:members] Rack::Utils.parse_nested_query(members)
    #members.each do |member|
      #id = member.kk
  #end


  def show()
    @projects = current_user.projects
    if @projects == nil then
      flash[:caution] = 'you have no projects'
    end
  end


  def show_posts()
    if project.members.include?(current_user) then
      @posts = project.posts
    else
      flash[:caution] = 'you have no access'
      redirect_to request.referer
    end
  end

  def destroy()
    # need to define "current_user" method
    # "members" defined in project model
    if project && current_user.id in project.members.id
      project.destroy
      flash[:success] = 'deleted project'
    else
      flash[:danger] = 'failed to delete project'
    end

    # redirect to "home"
    # use command "$ rake routes" to see prefix
    redirect_to :root_path
  end

  def edit_metadata()
    # need to define "current_user"
    # "members" defined in project model
    if project && current_user.id in project.members.id
      @name = project.name
      @caption = project.caption
    end

    # redirect to referer
    redirect_to request.referer
  end
