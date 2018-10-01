class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:sessions][:email].downcase)
    if user && user.authenticate(params[:sessions][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      login user
      flash[:success] = "ログインしました"
      redirect_to user
    else
      flash.now[:danger] = 'アドレスまたはパスワードを確認してください' # 本当は正しくない
      render 'new'
    end
  end

  def destroy
  end
end
