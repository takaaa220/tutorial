class StaticPagesController < ApplicationController
  def home
    # if文内が2行以上だと前置if，1行だと後置if
    if logged_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def about
  end

  def help
  end

  def contact
  end
end
