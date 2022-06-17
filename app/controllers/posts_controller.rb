class PostsController < ApplicationController

  def show
    @post = Post.find(params[:id])
  end

  def create
    #formからcaptionを受け取ってレコード作成
    post = Post.create(post_params)
    post.save
    redirect_to root_path
  end

  def post_params
    #悪意あるユーザからの情報を受け取らないように
    params.require(:post).permit(:caption)
  end

end
