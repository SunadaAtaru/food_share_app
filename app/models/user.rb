class User < ApplicationRecord
  # ユーザーが保存される前にメールアドレスをすべて小文字に変換
  before_save :downcase_email
  # ユーザー作成前に、有効化用トークンとダイジェストを生成
  before_create :create_activation_digest  

  # 仮想の属性としてremember_token, activation_tokenを設定
  attr_accessor :remember_token, :activation_token,  :reset_token
  
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
    self.remember_token = User.new_token # トークンを生成
    update_column(:remember_digest, User.digest(remember_token)) # ハッシュ化して保/
 _ end

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

  def activation_token_valid?
    (Time.zone.now - created_at) < 24.hours  # または適切な期間
  end

  # パスワードリセット用の属性を設定するメソッド
  def create_reset_digest
    # SecureRandomを使用して作成した安全なランダムトークンを設定
    self.reset_token = User.new_token
    
    # データベースを更新：
    # - reset_digest: トークンをハッシュ化して保存
    # - reset_sent_at: 現在時刻を保存
    # update_columnsを使用することでバリデーションをスキップし、
    # データベースを1回の操作で更新
    update_columns(reset_digest: User.digest(reset_token),
                  reset_sent_at: Time.zone.now)
  end

  # パスワードリセット用メールを送信するメソッド
  def send_password_reset_email
    # UserMailerクラスのpassword_resetメソッドを呼び出し
    # deliver_nowで即時メール送信を実行
    UserMailer.password_reset(self).deliver_now
  end

  # パスワードリセットの期限切れをチェックするメソッド
  def password_reset_expired?
    # reset_sent_atが2時間以上前の場合はtrueを返す
    # 2.hours.agoは現在時刻から2時間前の時間を返す
    reset_sent_at < 2.hours.ago
  end

  private  # この行以降のメソッドは、このクラス内でのみ使用可能

  # メールアドレスを小文字に変換するメソッド
  def downcase_email
    # self.email：このユーザーインスタンスのemailプロパティを指す
    # email.downcase：現在のメールアドレスを小文字に変換
    #
    # 例：
    # あるユーザーのメールアドレスが "User@Example.com" の場合
    # "User@Example.com".downcase => "user@example.com"
    
    self.email = email.downcase
    
    # 別の書き方：
    # self.email = self.email.downcase
    # email.downcase! # 破壊的メソッドを使用する場合
  end

  # アカウント有効化のためのトークンとダイジェストを作成するメソッド
  def create_activation_digest
    # 1. トークンの生成
    # User.new_tokenで安全なランダムな文字列を生成
    # 生成されたトークンは一時的な属性（activation_token）に保存
    self.activation_token = User.new_token
    # 生成例："q5lt38hQDc_959PVoo6b7A"

    # 2. ダイジェストの作成
    # 生成したトークンをハッシュ化してデータベースに保存
    # User.digest(activation_token)でハッシュ化
    # 生成されたハッシュはactivation_digestカラムに保存
    self.activation_digest = User.digest(activation_token)
    # ハッシュ化例："$2a$12$UNqJ45z0wMqyxC8RFP.M1OJYWf6wPSxXXGxpuNW8IC"

    # このメソッドが実行される流れ：
    # 1. ユーザーが新規登録フォームを送信
    # 2. before_createコールバックでこのメソッドが呼ばれる
    # 3. トークンとダイジェストが生成される
    # 4. ダイジェストはデータベースに保存
    # 5. トークンは有効化メールに含めて送信される
  end

# 補足：
# - privateキーワードを使用する理由：
#   - これらのメソッドはクラス内部の処理としてのみ使用
#   - 外部からの直接呼び出しを防ぐ
#   - コードの安全性とカプセル化を高める
#
# - selfを使用する理由：
#   - 単なる email = という代入は、ローカル変数の作成と解釈される
#   - self.email = とすることで、インスタンス変数への代入だと明示
end
