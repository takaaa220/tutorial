class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user # 一時cookie に User_id 追加
      remember user # 署名付き永続cookie に 暗号化したRemember_token，user_id を追加
      flash[:success] = "ログインしました"
      redirect_to user
    else
      flash.now[:danger] = 'アドレスまたはパスワードを確認してください' # 次のページのみ表示
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
