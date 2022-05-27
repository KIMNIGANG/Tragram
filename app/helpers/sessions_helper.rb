module SessionsHelper
  # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    return unless (user_id = session[:user_id])

    @current_user ||= User.find_by(id: user_id)
  end

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
	  !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end