class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token # 暗号化前, 有効化トークン

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, {presence: true, length: {maximum: 50}}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, {presence: true, uniqueness: {case_sensitive: false},
                    length: {maximum: 140},
                    format: {with: VALID_EMAIL_REGEX}}

  has_secure_password
  # 編集時は空白でも送信できるようにする（新規登録時はhas_secure_passwordのバリデーションでnilは通らない）
  validates :password, {presence: true, length: {minimum: 6}, allow_nil: true}

  # 渡された文字列のハッシュを返す
  def self.digest(string)
    # User.digestとも書ける
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                        BCrypt::Engine.cost # costとはハッシュを計算するための計算コスト
    BCrypt::Password.create(string, cost: cost) # string で渡されたパスワードを暗号化
  end

  # ランダムなトークンを返す (非暗号)
  def self.new_token
    # User.new_tokenとも書ける
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためのユーザをデータベースに記憶
  def remember
    self.remember_token = User.new_token # 22桁のトークンを発行
    update_attribute(:remember_digest, User.digest(remember_token)) # Remember_tokenを暗号化して，データベースに追加
  end

  # 渡されたトークンがダイジェストと一致したらTrue
  def authenticated?(remember_token)
    return false if remember_digest.nil? # remember_digestがnilの場合の例外発生防止
    BCrypt::Password.new(remember_digest).is_password?(remember_token) # remember_digest は self.remember_digest と同様
  end

  # ユーザのログイン情報を破棄
  def forget
    update_attribute(:remember_digest, nil)
  end

  private

    # メールアドレスを全て小文字にする
    def downcase_email
      self.email.downcase!
    end

    # 有効化トークンとダイジェストを作成及び代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
