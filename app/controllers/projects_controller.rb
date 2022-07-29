class ProjectsController < ApplicationController
  require 'rack'

  def show()
    # indexpage
    # post一覧とメタデータ
    # member確認未実装
    project = Project.find_by(id: params[:id])

    unless project then
      flash[:caution] = 'project doesnt exist'
      redirect_to request.referer
    end

    @project = project
    @posts = []
    @members = []
    project.users.each do |u|
      @members.push(u.name)
    end

    posts = Post.where(project_id: params[:id])

    posts.each do |post|
      url = ''
      post.images.each do |image|
        if image.media_type == 'IMAGE' then

          # instagram
          if id = image.instagram_id then
            unless token = current_user.instagramtoken.token then
              flash[:danger] = 'Instagramの権限が切れています'
            end
            url = get_media(token, id)[0]['media_url']

          # cloudinary
          else
            url = image.url
          end
          break
        end
      end
      @posts.push({:name => post.name, :caption => post.caption, :image => url, :id => post.id})
    end

    @location = []
    project.posts.each do |post|
      if post.location then
        name = post.location.name ||= nil
        lat = post.location.lat ||= nil
        lng = post.location.lng ||= nil
      end
      @location.push({:name => name, :lat => lat, :lng => lng})
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
      user_project.save
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

  def invite
    @invite = UserProject.new
  end

  def invite_create
    if UserProject.exists?(user_id: @current_user.id, project_id: params[:id])
      redirect_to action: :show, id: params[:id]
    else
      invite = UserProject.create(user_id: @current_user.id, project_id: params[:id])
      invite.save
      redirect_to action: :show, id: invite.project_id
    end
  end

end


private

  def projects_params
    params.require(:project).permit(:name,:caption)
  end

  def project_update_params
    params.require(:project).permit(:name,:caption)
  end
