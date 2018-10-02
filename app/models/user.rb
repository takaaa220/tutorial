class User < ApplicationRecord
  attr_accessor :remember_token # 暗号化前

  before_save {email.downcase!}
  validates :name, {presence: true, length: {maximum: 50}}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, {presence: true, uniqueness: {case_sensitive: false},
                    length: {maximum: 140},
                    format: {with: VALID_EMAIL_REGEX}}

  has_secure_password
  validates :password, {presence: true, length: {minimum: 6}}

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
    BCrypt::Password.new(remember_digest).is_password?(remember_token) # remember_digest は self.remember_digest と同様
  end

  # ユーザのログイン情報を破棄
  def forget
    update_attribute(:remember_digest, nil)
  end
end
