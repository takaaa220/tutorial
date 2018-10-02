require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user # @userがCurrent_userであるか
    assert is_logged_in? # ログインしているか
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user # @userが持つのと，Cookiesが持つremember_digestが異なる場合CurrentUserはnil
  end
end
