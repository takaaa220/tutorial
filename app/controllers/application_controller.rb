class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private
  
  # ログイン済みのユーザかどうか
    def logged_in_user
      unless logged_in? # unless: 条件式が偽の場合のみ
        store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_url
      end
    end

end
