require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
  end

  # 編集失敗時の簡単なテスト
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: {name: "",
                                email: "invalid@invalid",
                                password: "foo",
                                password_confirmation: "bar"}}
    assert_template "users/edit"
    assert_select "div.alert", "The form contains 4 errors."
  end

  # 編集成功時のテスト
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    name = "Foo bar"
    email = "foo@bar.com"
    # password とpassword confirmation は変更しなくても編集できるようにする
    patch user_path(@user), params: { user: {name: name,
                                email: email,
                                password: "",
                                password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload # データベースから最新のユーザ情報を読み込む
    # データベースと照合
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  # ログインしていないユーザが編集ページにアクセスできないかどうか
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # ログインしていないユーザが編集を行うことができないかどうか
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { name: @user.name, email: @user.email}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other)
    patch user_path(@user), params: { name: @user.name, email: @user.email}
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {user: { name: name,
                                email: email,
                                password: "",
                                password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
