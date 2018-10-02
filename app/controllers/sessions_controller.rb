class SessionsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user # 一時cookie に User_id 追加
      # 署名付き永続cookieに暗号化したRemember_token，user_id を追加, もしくは永続的セッションの破棄
      params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
      flash[:success] = "ログインしました"
      redirect_to @user # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      flash.now[:danger] = 'アドレスまたはパスワードを確認してください' # 次のページのみ表示
      render 'new'
    end
  end

  def destroy
    # ログインしている場合のみログアウト（ウィンドウを二つ開いている場合などに起こりうる）
    log_out if logged_in?
    redirect_to root_url
  end
end
