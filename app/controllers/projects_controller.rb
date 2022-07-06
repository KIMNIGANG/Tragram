class ProjectsController < ApplicationController
  require 'rack'

  def show()
    # indexpage
    # post一覧とメタデータ
    # member確認未実装
    project = Project.find_by(id: params[:id])
    if project then
      @project = project
      @posts = Post.where(project_id: params[:id])
    else
      flash[:caution] = 'project doesnt exist'
      redirect_to request.referer
    end
  end

  # projectのcreate
  # ユーザー確認 -> 作成 -> リダイレクト
  def create()
    if current_user then
      #project = current_user.projects.create(params.require(:project).permit(:name, :caption))
      project = Project.create(projects_params)
      project.save
      user_project = UserProject.create(user_id: @current_user.id, project_id: project.id)
      redirect_to action: :show, id: project.id
      #redirect_to controller: :users, action: :show, id: @current_user.id
    else
      flash[:caution] = 'no user'
    end
  end

  def edit()
    @project = Project.find_by(id: params[:id])
    if !@project.users.include?(current_user) then
      flash[:danger] = 'only members can edit'
      redirect_to request.referer
    end
  end

 # 後で　viewも一緒に
  def update()
  # params: name, caption
  # フォーム送信でアクション発火
    project = Project.find_by(id: params[:id])
    if !project then
      flash[:caution] = 'no project found'
    elsif !project.users then
      flash[:caution] = 'not a member'
    elsif project.users.include?(current_user) then
      project.update(project_update_params)
    end
    redirect_to action: :show, id: project.id
  end

  # project削除
  def destroy()
    project = Project.find(params[:id])
    user_project = UserProject.find_by(project_id: params[:id])
    if UserProject.exists?(user_id: @current_user.id, project_id: params[:id])
      project.destroy
      user_project.destroy
      flash[:caution] = 'destroyed project'
    else
      flash[:caution] = "coudln't destroy project"
    end
    redirect_to controller: :users, action: :show, id: @current_user.id
  end

end


private

  def projects_params
    params.require(:project).permit(:name,:caption)
  end

  def project_update_params
    params.require(:project).permit(:name,:caption)
  end
