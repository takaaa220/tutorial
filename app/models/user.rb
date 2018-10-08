class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                          foreign_key: "follower_id",
                          dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                          foreign_key: "followed_id",
                          dependent: :destroy

  # has_many :followeds, through: :active_relationshipsがdefault
  # user.followedsをuser.followingに変更
  has_many :following, through: :active_relationships, source: :followed
  # source: :follower は省略可
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token # 暗号化前

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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil? # (remember or activation)_digestがnilの場合の例外発生防止
    BCrypt::Password.new(digest).is_password?(token) # remember_digest は self.remember_digest と同様
  end

  # ユーザのログイン情報を破棄
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attributes(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定用の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定用のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はTrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # ユーザのステータスフィードを返す
  def feed
    # 試作
    # Micropost.where("user_id=?", id)
    # 本物(効率悪し)
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #     following_ids: following_ids, user_id: id)
    # 本物(効率よし)
    following_ids = "SELECT followed_id FROM relationships
                 WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                 OR user_id = :user_id", user_id: id)
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
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
