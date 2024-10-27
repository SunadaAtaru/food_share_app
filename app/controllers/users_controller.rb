# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # ログインユーザーのみアクセス可能なアクションを指定
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  # 正しいユーザーのみアクセス可能なアクションを指定
  before_action :correct_user,   only: [:edit, :update]
  # 管理者のみアクセス可能なアクションを指定
  before_action :admin_user,     only: :destroy
  # destroyアクション実行前に対象ユーザーを設定
  before_action :set_user, only: [:destroy]
  # 管理者または自身のアカウントのみdestroyアクション実行可能
  before_action :correct_user_or_admin, only: [:destroy]
  # `:show` アクションが実行される前に `activated_user` メソッドを実行する
  before_action :activated_user, only: [:show]
  
  # ユーザーを登録日時の降順（新しい順）で並べ替え、1ページに10件ずつ表示
  def index
    @users = User.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end
  
  
  
  # 新規ユーザー登録フォームを表示
  def new
    @user = User.new  # 新規ユーザーオブジェクトを作成し、フォームに渡す
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 更新に成功した場合の処理
    else
      render 'edit'
    end
  end
  
  # 新規ユーザーを作成
  def create
    @user = User.new(user_params)  # ユーザーのパラメータを使って新しいユーザーを作成
    puts "User params: #{user_params.inspect}"  # 受け取ったパラメータを確認
    puts "User valid?: #{@user.valid?}"         # バリデーションの結果を確認
    if @user.save  # ユーザーの保存に成功した場合
      puts "User saved successfully" # デバッグ用
      puts "User details: #{@user.inspect}"
      @user.send_activation_email  # 有効化メールを送信
      puts "Activation email sent" # デバッグ用
      flash[:info] = "メールを確認して、アカウントを有効化してください。"  # メール送信後の通知メッセージ
      redirect_to root_url  # トップページにリダイレクト
    else
      puts "User save failed" # デバッグ用
      
      render :new  # 保存に失敗した場合、新規登録フォームを再表示
      puts "Validation errors: #{@user.errors.full_messages}"  # 具体的なエラーメッセージを確認
    end
  end
  
  
  # ユーザー詳細ページを表示
  def show
    @user = User.find(params[:id])  # URLのパラメータからユーザーIDを取得し、そのユーザーをデータベースから検索して表示
  end

  def destroy
    # @userはset_userメソッドで既に設定済み
    @user.destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
 
  

 

  private  # 以降のメソッドはコントローラ内でのみ使用可能

  # ユーザーが有効化されているかどうか確認するメソッド
  # `@user` には指定されたIDのユーザーを取得し、それが有効化されているかを確認する
  # 有効化されていない場合はルートページにリダイレクトする
  def activated_user
    @user = User.find(params[:id])  # パラメータからユーザーIDを取得し、そのユーザーをデータベースから検索
    # ユーザーが有効化されていない場合はルートページにリダイレクト
    redirect_to root_url unless @user.activated?
  end

  # ユーザーが管理者または削除対象のユーザー自身かを確認するメソッド
  def correct_user_or_admin
    @user = User.find(params[:id])
    unless current_user.admin? || current_user?(@user)
      flash[:danger] = "You are not authorized to delete this user"
      redirect_to root_url
    end
  end

  
  # Strong Parametersを使用してパラメータを制限
  def user_params
    # フォームから送信されるデータのうち、許可されたキーのみを抽出する
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
  
  # ログインしていない場合、ログインページにリダイレクト
  def logged_in_user
    unless logged_in?  # ログインしているかどうかを確認する
      store_location  # 現在のページを保存して、ログイン後にリダイレクトできるようにする
      flash[:danger] = "Please log in."  # ログインを促すメッセージを表示
      redirect_to login_url  # ログインページにリダイレクト
    end
  end
  
  # 正しいユーザーかどうかを確認
  def correct_user
    @user = User.find(params[:id])  # パラメータからユーザーIDを取得し、そのユーザーを検索
    # ログイン中のユーザーが指定されたユーザーと一致しない場合、ホームページにリダイレクト
    redirect_to(root_url) unless current_user?(@user)  
  end

  # 対象ユーザーを@userに設定するメソッド
  def set_user
    @user = User.find(params[:id])
  end
  
  # 管理者かどうかを確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?  # ログイン中のユーザーが管理者でない場合、ホームページにリダイレクト
  end
end
