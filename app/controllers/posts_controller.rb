class PostsController < ApplicationController
  def create
    #formからcaptionを受け取ってレコード作成
    if current_user
        current_user.posts.create(caption:post_params["caption"])
        redirect_to request.referer
    end
  end

  def destroy
    #削除
  end

  def edit
    #編集情報を渡す
    @post =  Post.find(params["post_id"].to_i)
  end

  def update
    #情報を更新
    @post = Post.find(params["post_id"].to_i)
    @post = Post.update(post_params)
    redirect_to posts.referer #リダイレクト先どこがいい?
  end


  private


  def post_params
    #悪意あるユーザからの情報を受け取らないように
    params.require(:post).permit(:caption,:project_id,:id) #?????
  end

end
