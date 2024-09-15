# app/models/user.rb
class User < ApplicationRecord
  before_save :downcase_email
  attr_accessor :remember_token
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :username, presence: { message: "can't be blank" }, 
                       uniqueness: true,
                       length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  has_secure_password

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)   # クラスメソッドとして定義するためにselfを使用
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
 
  # ランダムなトークンを生成
  # def User.new_token
    # SecureRandom.urlsafe_base64
  # end
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  # トークンをダイジェスト化
  # def User.digest(token)
  #   BCrypt::Password.create(token)
  # end
  
  # ユーザーを記憶する
  # def remember
  #   self.remember_token = User.new_token
  #   update_attribute(:remember_digest, User.digest(remember_token))
  # end
  def remember
    self.remember_token = User.new_token
    update_column(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_column(:remember_digest, nil)
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end

