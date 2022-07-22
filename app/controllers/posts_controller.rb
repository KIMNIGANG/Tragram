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
    unless @post = post?(params[:id]) then
      redirect_to root_path and return
    end

    # member check
    if !@post.project.users.include?(current_user) then
      puts "no access (post#show)"
      redirect_to root_path
    end
      @location = []
      if @post.location then
        name = @post.location.name ||= ""
        lng = @post.location.lng ||= ""
        lat = @post.location.lat ||= ""
        @location.push({:name => name, :lng => lng, :lat => lat})
      end
    # location info
    if !@post.location.nil? then
      @location_name = @post.location.name ||= ""
      @location_lng = @post.location.lng ||= ""
      @location_lat = @post.location.lat ||= ""
    end

    # image urls
    @images = []
    token = current_user.instagramtoken.token if current_user.instagramtoken
    @post.images.each do |media|
      url = ''
      media_type = ''

      # instagram
      if media.instagram_id then
        unless token then
          flash[:alert] = 'Instagramの権限が切れています'
        end
        res = get_media(token, media.instagram_id)
        url = res[0]['media_url']

      # cloudinary
      elsif media.url then
        url = media.url

      end

      @images.push({:media_type => media.media_type, :url => url})

    end
  end


      flash[:alert] = '投稿がありません'
      redirect_to request.referer
    elsif current_user != post.user then
      flash[:alert] = '編集権限がありません'
      redirect_to request.referer
    else
      post.update(post_update_params)
    end
    redirect_to controller: :projects, action: :show, id: post.project_id
  end

  def location_update()
    puts "locationupdate--"
    unless post = post?(params[:id]) then
      flash[:alert] = '投稿がありません'
      redirect_to request.referer
    end

    if current_user != post.user then
      flash[:alert] = '編集権限がありません'
      redirect_to request.referer
    else
      name = params[:name]
      lat = params[:lat].to_f
      lng = params[:lng].to_f
      if post.location then
        post.location.update(name: name, lat: lat, lng: lng, post_id: post.id)
      else
        Location.create(name: name, lat: lat, lng: lng, post_id: post.id)
      end
      flash[:notice] = '位置情報を登録しました'
      redirect_to "/posts/#{post.id}/"
    end
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
end
