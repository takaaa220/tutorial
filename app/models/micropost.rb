class Micropost < ApplicationRecord
  belongs_to :user
  # ずっと(scopeを使えば任意のとき呼び出すことができる)
  # ex) scope :desc, -> {order(created_at: :desc)} usage) Micropost.desc
  default_scope -> { order(created_at: :desc)}

  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
