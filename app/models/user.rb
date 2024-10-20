class User < ApplicationRecord
  # ユーザーが保存される前にメールアドレスをすべて小文字に変換
  before_save :downcase_email
  # ユーザー作成前に、有効化用トークンとダイジェストを生成
  before_create :create_activation_digest  

  # 仮想の属性としてremember_token, activation_tokenを設定
  attr_accessor :remember_token, :activation_token  
  
  # 有効なメールアドレスのフォーマットを定義
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # ユーザー名のバリデーション
  validates :username, presence: { message: "can't be blank" }, # 空でないことを検証
                       uniqueness: true,                        # 一意であることを検証
                       length: { maximum: 50 }                  # 50文字以内であることを検証
  
  # メールアドレスのバリデーション
  validates :email, presence: true,                              # 空でないことを検証
                    length: { maximum: 255 },                    # 255文字以内であることを検証
                    format: { with: VALID_EMAIL_REGEX },         # 正規表現でフォーマットを検証
                    uniqueness: { case_sensitive: false }        # 大文字小文字を区別せず一意であることを検証
  
  # パスワードを安全に管理するための機能を提供（パスワードのハッシュ化など）
  has_secure_password
  
  # パスワードのバリデーション
  validates :password, presence: true,                           # 空でないことを検証
                       length: { minimum: 6 },                   # 6文字以上であることを検証
                       allow_nil: true                          # パスワードがnilの場合はバリデーションをスキップ

  # 渡された文字列のハッシュ値を返すクラスメソッド
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを生成するクラスメソッド
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  # ユーザーを記憶する（ログイン状態を維持する）
  def remember
    self.remember_token = User.new_token
    update_column(:remember_digest, User.digest(remember_token))
  end

  # 与えられた属性がダイジェストと一致したら true を返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_column(:remember_digest, nil)
  end

  # アカウントを有効化する
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

private

  # メールアドレスをすべて小文字に変換する
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成・割り当てる
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
