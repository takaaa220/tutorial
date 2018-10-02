require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followd by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert_redirected_to @user # リダイレクト先が正しいかチェック
    follow_redirect! # 実際に移動
    assert_template 'users/show' # 適切にテンプレートが選ばれているか
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path # delete メソッドのlogout_pathを呼ぶ
    assert_not is_logged_in? # ログアウトしているはず
    assert_redirected_to root_url
    # 二つ目のウィンドウでログアウトするとどうなるか
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: "1") # cookie存在している状態でのログイン
    # assert_not_empty cookies['remember_token'] # テスト内ではCookiesメソッドにシンボルは使えない
    # assignsを使うとControllerで定義したインスタンス変数にテストからアクセルできる
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remembering" do
    # cookie を保存してログイン
    log_in_as(@user, remember_me: "1")
    delete logout_path # ログアウト
    # cookie を削除してログイン
    log_in_as(@user, remember_me: "0")
    assert_empty cookies['remember_token']
  end
end
