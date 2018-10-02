module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザのセッションの永続化
  def remember(user)
    user.remember # 暗号化したremember_tokenを発行，データベース（remember_digest）に追加
    cookies.permanent.signed[:user_id] = user.id # 署名つき永続CookieにUser idを追加
    cookies.permanent[:remember_token] = user.remember_token # 永続Cookieにremember_token
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # cookie に対応するユーザを返す
  def current_user
    if user_id = session[:user_id] # 代入して存在確認
      @current_user ||= User.find_by(id: user_id)
    elsif user_id = cookies.signed[:user_id] # 代入して存在確認
      user = User.find_by(id: user_id) # user_id でユーザを検索
      # ユーザが存在し，CookieのRemember_tokenがデータベース上のremember_digestと一致するか
      if user && user.authenticated?(cookies[:remember_token])
        # 自動ログイン
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザがログインしていればTrue，していなければFalseを返す
  def logged_in?
    !current_user.nil?
  end
end
