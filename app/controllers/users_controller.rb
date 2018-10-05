class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "メールを確認してアカウントを有効にしてください"
      redirect_to root_url
    else
      render "new"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザ情報を変更しました"
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザを削除しました"
    redirect_to users_url
  end

  private
    # strong parameter の指定
    def user_params
      # user に対し，name, email, password, password_confirmationのみ送信を許可する
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # before action

    # ログイン済みのユーザかどうか
    def logged_in_user
      unless logged_in? # unless: 条件式が偽の場合のみ
        store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_url
      end
    end

    # 正しいユーザかどうか
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
