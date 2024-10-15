class User < ApplicationRecord
  # ユーザーが保存される前にメールアドレスをすべて小文字に変換
  before_save :downcase_email
  
  # 仮想の属性（データベースには存在しない属性）としてremember_tokenを設定
  attr_accessor :remember_token
  
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
    # パスワードのハッシュ化のためのコストを設定（開発環境では低く設定）
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    # ハッシュ値を生成して返す
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを生成するクラスメソッド
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  # ユーザーを記憶する（ログイン状態を維持する）
  def remember
    # ランダムなトークンを生成してremember_tokenに設定
    self.remember_token = User.new_token
    # remember_digestカラムにトークンのハッシュ値を保存
    update_column(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    # remember_digestがnilの場合はfalseを返す
    return false if remember_digest.nil?
    # トークンをダイジェスト化して一致するか確認
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する（ログアウト時に呼び出す）
  def forget
    # remember_digestカラムをnilに設定
    update_column(:remember_digest, nil)
  end

  private

  # メールアドレスをすべて小文字に変換するプライベートメソッド
  def downcase_email
    self.email = email.downcase
  end
end
