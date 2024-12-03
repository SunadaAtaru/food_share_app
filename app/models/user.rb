class User < ApplicationRecord
  # ユーザーが保存される前にメールアドレスをすべて小文字に変換
  before_save :downcase_email
  # ユーザー作成前に、有効化用トークンとダイジェストを生成
  before_create :create_activation_digest  

  mount_uploader :avatar, AvatarUploader


  # 仮想の属性としてremember_token, activation_tokenを設定
  attr_accessor :remember_token, :activation_token,  :reset_token, :skip_password_validation  # この行を追加
  
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
  
  # バリデーション
  validate :avatar_size_validation

  # 渡された文字列のハッシュ値を返すクラスメソッド
  # @param string ハッシュ化する文字列
  # @return ハッシュ化された文字列
  def self.digest(string)
    # 開発環境ではコストを下げて高速化、本番環境では標準のコストを使用
    cost = ActiveModel::SecurePassword.min_cost ? 
          BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    # BCryptを使用して文字列をハッシュ化
    BCrypt::Password.create(string, cost: cost)
  end
  
  # セキュアなランダムトークンを生成するクラスメソッド
  # @return ランダムな64文字のトークン
  def self.new_token
    SecureRandom.urlsafe_base64  # URL-safeなbase64でエンコードされたランダムな文字列を生成
  end
  
  # 永続セッション用のユーザーを記憶する
  def remember
    self.remember_token = User.new_token  # 仮想属性にトークンを設定
    update_column(:remember_digest, User.digest(remember_token))  # トークンのハッシュ値をDBに保存
  end
  
  # トークンがダイジェストと一致することを確認する汎用的な認証メソッド
  # @param attribute 認証する属性（:remember, :activation, :reset など）
  # @param token 認証するトークン
  # @return boolean 認証成功ならtrue、失敗ならfalse
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")  # 対応するダイジェストを動的に取得
    return false if digest.nil?  # ダイジェストがnilの場合は認証失敗
    BCrypt::Password.new(digest).is_password?(token)  # トークンとダイジェストを比較
  end
  
  # ユーザーのログイン情報を破棄する（ログアウト用）
  def forget
    update_column(:remember_digest, nil)  # remember_digestをnilに設定
  end
  
  # アカウントを有効化する
  def activate
    # 複数のカラムを一度に更新（activated: trueと有効化時刻）
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # アカウント有効化メールを送信する
  def send_activation_email
    # 非同期でアクティベーションメールを送信
    UserMailer.account_activation(self).deliver_now
  end
  
  # アクティベーショントークンの有効期限をチェック（24時間以内）
  # @return boolean トークンが有効ならtrue、期限切れならfalse
  def activation_token_valid?
    (Time.zone.now - created_at) < 24.hours  # アカウント作成から24時間以内かチェック
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

  # パスワードを任意入力可能にするためのメソッド
  # @skip_password_validationフラグを設定することで、
  # パスワードの入力を必須としないケースを制御します
  def skip_password_validation
    @skip_password_validation = true
  end


  private  # この行以降のメソッドは、このクラス内でのみ使用可能


  # has_secure_passwordのパスワードバリデーションをカスタマイズするメソッド
  # @return [Boolean] パスワードが必須かどうか
  # @skip_password_validation == true の場合：
  #   - パスワードバリデーションをスキップ（false を返す）
  # @skip_password_validation == false の場合：
  #   - 通常のhas_secure_passwordの動作を継続（super でデフォルトの動作を実行）
  def password_required?
    return false if @skip_password_validation
    super  # has_secure_passwordのデフォルトの判定処理を実行
  end

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
  def avatar_size_validation
    if avatar.size > 5.megabytes
      errors.add(:avatar, "画像サイズは5MB以下にしてください")
    end
  end
end
