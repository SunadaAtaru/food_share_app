class PasswordResetsController < ApplicationController
  # 各アクションの実行前に特定の処理を行うフィルター
  # editとupdateアクションの前にユーザー取得を実行
  before_action :get_user,         only: [:edit, :update]
  # editとupdateアクションの前にユーザーの正当性を確認
  before_action :valid_user,       only: [:edit, :update]
  # editとupdateアクションの前に期限切れチェックを実行
  before_action :check_expiration, only: [:edit, :update]
  # updateアクション専用のパスワード存在チェック
  # パスワードが空の状態での更新を防止
  before_action :check_password_presence, only: [:update]

  # GET /password_resets/new
  # パスワードリセットのエントリーポイント
  # ユーザーがパスワードを忘れた際に最初にアクセスするページ
  def new
    # 特に処理は不要。ビューでメールアドレス入力フォームを表示
  end

  # POST /password_resets
  # パスワードリセットプロセスの開始処理
  # メールアドレスを受け取り、リセット用のメールを送信
  def create
    # パラメータから送信されたメールアドレスを小文字に変換して正規化
    # データベースでの検索時に大文字小文字の違いによる問題を防ぐ
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    
    if @user
      # ユーザーが存在する場合の処理
      @user.create_reset_digest     # セキュアなリセットトークンとダイジェストを生成
      @user.send_password_reset_email    # リセットリンクを含むメールを送信
      flash[:info] = "パスワード再設定用のメールを送信しました"  # 成功通知
      redirect_to root_url  # トップページへ遷移
    else
      # ユーザーが見つからない場合
      # セキュリティ上、具体的なエラー内容は最小限に
      flash.now[:danger] = "Email address not found"  # エラーメッセージ
      render 'new'  # 入力フォームを再表示
    end
  end

  # GET /password_resets/:id/edit
  # パスワード再設定フォームの表示
  # params[:id]にはリセットトークンが含まれる
  def edit
    # パラメータのメールアドレスからユーザーを検索
    # @user = User.find_by(email: params[:email])  このbefore_actionのget_userに処理をまとめる
    # ユーザーの存在確認とトークンの認証
    # authenticated?メソッドでトークンの正当性を検証
    unless @user && @user.authenticated?(:reset, params[:id])
      redirect_to root_url  # 不正な場合はトップページへ
    end
  end

  # PATCH/PUT /password_resets/:id
  # 新しいパスワードでの更新を実行
  # フォームから送信された新パスワードでユーザー情報を更新
  def update
    if params[:user][:password].empty?
      # パスワードが空の場合
      # モデルのバリデーションとは別に、コントローラレベルでもチェック
      @user.errors.add(:password, :blank)  # エラーメッセージを追加
      render :edit  # 編集フォームを再表示
    elsif @user.update(user_params)
      # パスワード更新成功時の処理
      log_in @user  # ユーザーを自動的にログイン状態に
      @user.update_attribute(:reset_digest, nil)  # セキュリティのためリセットトークンを無効化
      redirect_to @user, notice: "パスワードが更新されました"  # 成功メッセージと共にリダイレクト
    else
      # その他のバリデーションエラー時
      # パスワードの長さ不足や確認用パスワードとの不一致など
      render :edit  # エラーメッセージと共に編集フォームを再表示
    end
  end

  private
    # Strong Parameters設定
    # セキュリティ対策として許可するパラメータを明示的に指定
    def user_params
      # パスワードとその確認用フィールドのみを許可
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeアクション用メソッド群
    
    # ユーザー取得メソッド
    # パラメータのメールアドレスに基づいてユーザーを検索
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # ユーザーの正当性確認メソッド
    # 複数の条件を確認し、一つでも満たさない場合はリダイレクト
    def valid_user
      unless (@user && # ユーザーが存在すること
              @user.activated? && # アカウントが有効化済みであること
              @user.authenticated?(:reset, params[:id])) # リセットトークンが有効であること
        # 不正なアクセスとみなしトップページへリダイレクト
        # セキュリティのため、具体的なエラー理由は表示しない     
        redirect_to root_url
      end
    end

    # パスワードリセットの期限切れチェック
    # 一定時間（典型的には2時間）経過後のリセットを防止
    def check_expiration
      if @user.password_reset_expired? # reset_sent_atと現在時刻を比較
        flash[:danger] = "Password reset has expired."  # 期限切れ通知
        redirect_to new_password_reset_url  # リセット申請フォームへ
      end
    end

    # パスワードの存在チェック
    # updateアクション専用の追加的なバリデーション
    def check_password_presence
      if params[:user][:password].empty?
        @user.errors.add(:password, :blank)  # エラーメッセージを追加
        render :edit  # 編集フォームを再表示
      end
    end
end