class ProjectsController < ApplicationController
  require 'rack'

  def show()
    # indexpage
    # post一覧とメタデータ
    # member確認未実装
    project = Project.find_by(id: params[:id])
    if project then
      @project = project
    else
      flash[:caution] = 'project doesnt exist'
      redirect_to request.referer
    end
  end

  # projectのcreate
  # ユーザー確認 -> 作成 -> リダイレクト
  def create()
    if current_user then
      project = current_user.projects.create(params.require(:project).permit(:name, :caption))
      redirect_to action: :show, id: project.id
    else
      flash[:caution] = 'no user'
    end
  end

 # 後で　viewも一緒に
  def update()
    # need to define "current_user"
    # "members" defined in project model
    project = Project.find_by(id: params[:id])
    if !project then
      flash[:caution] = 'no project found'
    elsif !project.users then
      flash[:caution] = 'not a member'
    elsif project.users.include?(current_user) then 
      @name = project.name
      @caption = project.caption
    end
    redirect_to request.referer
  end

  # project削除
  def destroy()
    project = Project.find_by(id: params[:id])
    project.destroy()
    redirect_to root_path
  end

end
