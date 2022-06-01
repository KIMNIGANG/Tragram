class UsersController < ApplicationController
  def mypage
    #現在入っているprojectの一覧を表示する
  end

  def add_project
    if logged_in?
      #form_with使う
      #@new_project = current_user.projects.new
    end
  end

  #悪意あるユーザから意図しないパラメータを受け取らないために受け取るパラメータを事前に指定
  private

  def project_params

  end
end
