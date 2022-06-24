class PostsController < ApplicationController

  def new
    @posts = Post.all
    @post = Post.new
    @project_id = params[:project_id]
  end

  def create
    #formからcaptionを受け取ってレコード作成
    project = Project.find(@project_id)
    post = Post.create(post_params)
    post.save
    redirect_to controller: :project, action: :show, id: :@project_id
  end

  private

  def post_params
    #悪意あるユーザからの情報を受け取らないように
    params.require(:post).permit(:caption)
  end
end
