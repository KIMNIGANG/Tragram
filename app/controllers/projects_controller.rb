class ProjectsController < ApplicationController
  def add_post
    if logged_in?
      #form_with使う
      #@new_post = current_user.post.new????
    end
  end

  def show
    #全postを表示
  end

  #悪意あるユーザから意図しないパラメータを受け取らないために受け取るパラメータを事前に指定
  private

  def post_params

  end
end
