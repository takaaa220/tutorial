module SessionsHelper

  # 渡されたユーザでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザのセッションの永続化
  def remember(user)
    user.remember # 暗号化したremember_tokenを発行，データベース（remember_digest）に追加
    cookies.permanent.signed[:user_id] = user.id # 署名つき永続CookieにUser idを追加
    cookies.permanent[:remember_token] = user.remember_token # 永続Cookieにremember_token
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

  # 永続的セッションの破棄
  def forget(user)
    # データベースからremember_digest columnの除去
    # (remember_token, user_id が流出しても，ログアウト時にデータベースから破棄し，
    #  ログイン時に新しいremember_tokenを取得することで，不正ログインを防ぐ)
    user.forget
    # 永続Cookieの破棄
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # ユーザがログインしていればTrue，していなければFalseを返す
  def logged_in?
    !current_user.nil?
  end
end
