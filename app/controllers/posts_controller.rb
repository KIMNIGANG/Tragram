class PostsController < ApplicationController

  def new
    @posts = Post.all
    @post = Post.new
    session[:project_id] = params[:project_id]
  end

  def create
    #formからcaptionを受け取ってレコード作成
    project_id = session[:project_id]
    project = Project.find(session[:project_id])
    post = project.posts.create(post_params)
    post.save
    redirect_to controller: :projects, action: :show, id: post.project_id
  end

  def destroy()
    post = Post.find(params[:id])
    #if Post.exists?(user_id: @current_user.id, id: params[:id])
      post.destroy
      flash[:caution] = 'destroyed post'
    #else
      #flash[:caution] = "coudln't destroy post"
    #end
    redirect_to controller: :projects, action: :show, id: post.project_id
  end

  def show
    @post = Post.find_by(id: params[:id])
    # member check
    @location = @post.location
    @location ||= {name: "", lng: "", lat: ""}
  end

  def edit()
    @post = Post.find(params[:id])
    #if !@project.users.include?(current_user) then
      flash[:danger] = 'only members can edit'
      #redirect_to request.referer
    #end
  end


  def update()
    post = Post.find(params[:id])
    if !post then
      flash[:caution] = 'no post found'
    else
      post.update(post_update_params)
    end
    redirect_to controller: :projects, action: :show, id: post.project_id
  end

  def add_image()
    post = Post.find(params[:id])
    Cloudinary.config do |config|
      config.cloud_name = Rails.application.credentials.cloudinary[:cloud_name]
      config.api_key = Rails.application.credentials.cloudinary[:api_key]
      config.api_secret = Rails.application.credentials.cloudinary[:api_secret]
    end
  end

  private

  def post_params
    #悪意あるユーザからの情報を受け取らないように
    params.require(:post).permit(:caption, :image)
  end

  def post_update_params
    params.require(:post).permit(:caption)
  end
end
