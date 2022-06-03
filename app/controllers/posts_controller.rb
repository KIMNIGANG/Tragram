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
  end


  private


  def post_params
    #悪意あるユーザからの情報を受け取らないように
    params.require(:post).permit(:caption,:project_id,:id) #?????
  end

end
