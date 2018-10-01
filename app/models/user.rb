class User < ApplicationRecord
  before_save {email.downcase!}
  validates :name, {presence: true, length: {maximum: 50}}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, {presence: true, uniqueness: {case_sensitive: false},
                    length: {maximum: 140},
                    format: {with: VALID_EMAIL_REGEX}}

  has_secure_password
  validates :password, {presence: true, length: {minimum: 6}}

  # Fixture 作成のためのメソッド
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                        BCrypt::Engine.cost # costとはハッシュを計算するための計算コスト
    BCrypt::Password.create(string, cost: cost) # string で渡されたパスワードを暗号化
  end
end
