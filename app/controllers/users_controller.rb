class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザ登録が完了しました"
      redirect_to @user
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
      # redirect_to @user
    else
      render "edit"
    end
  end

  private
    # strong parameter の指定
    def user_params
      # user に対し，name, email, password, password_confirmationのみ送信を許可する
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
