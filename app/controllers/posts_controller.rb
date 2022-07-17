class PostsController < ApplicationController

  def new
    @posts = Post.all
    @post = Post.new
    session[:project_id] = params[:project_id]
  end

  def create
    if !current_user then
      flash[:danger] = 'register as a user'
      puts "no user"
      return redirect_to root_path
    end

    puts params[:name]
    puts params[:caption]

    #formからcaptionを受け取ってレコード作成
    project_id = session[:project_id]
    project = Project.find(session[:project_id])
    #post = project.posts.create(post_params)
    post = Post.create(post_params)

    project.posts << post
    current_user.posts << post

    return redirect_to controller: :projects, action: :show, id: post.project_id
  end

  def destroy()
    if post = post?(params[:id]) then
    else
      redirect_to root_path
    end

    # access
    if current_user != post.user then
      puts "you cannot delete ---"
      flash[:alert] = 'この投稿は削除できません'
      redirect_to post_path(id: post.id)
    else
      post.destroy
      flash[:notice] = '投稿を削除しました'
      redirect_to controller: :projects, action: :show, id: post.project_id, flash: {warning: "auaua"}
    end
  end


  def show
    if @post = post?(params[:id]) then
      # member check
      if !@post.project.users.include?(current_user) then
        puts "no access (post#show)"
        redirect_to root_path
      end
    end


  end

  def edit()
    if @post = post?(params[:id]) then
    else
      flash[:alert] = '投稿がありません'
      redirect_to request.referer
    end

    if current_user != @post.user then
      flash[:alert] = '編集権限がありません'
      redirect_to request.referer
    end
  end


  def update()
    if post = post?(params[:id]) then
      post.update(post_update_params)
    else
      redirect_to root_path
    end
    redirect_to controller: :projects, action: :show, id: post.project_id
  end

  def upload_image
    post = Post.find(params[:id])
    Cloudinary.config do |config|
      config.cloud_name = Rails.application.credentials.cloudinary[:cloud_name]
      config.api_key = Rails.application.credentials.cloudinary[:api_key]
      config.api_secret = Rails.application.credentials.cloudinary[:api_secret]
    end
    if params[:image]
      img = params[:image]
      upload = Cloudinary::Uploader.upload(img.path, :resource_type => :auto)
      img_url = upload['url']
      content_type = img.content_type
    end
    type = content_type.slice(0,5)
    if type == "image"
      media_type = "IMAGE"
    elsif type == "video"
      media_type  = "VIDEO"
    end
    img = Image.create(url: img_url, media_type: media_type)
    post.images << img
    redirect_to post_path(id: post.id)
  end

  private


  def post?(id)
    post = Post.find_by(id: id)
    if post.nil? then
      flash[:caution] = 'no post found'
      puts "post? -- no post found"
      return false
    else
      return post
    end
  end


  def post_params
    #悪意あるユーザからの情報を受け取らないように
    params.require(:post).permit(:caption, :name)

  end

  def post_update_params
    params.require(:post).permit(:caption)
  end

  def img_params
    params.require(:post).permit(:image)
  end


end
