# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # ログインユーザーのみアクセス可能なアクションを指定
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  # 正しいユーザーのみアクセス可能なアクションを指定
  before_action :correct_user,   only: [:edit, :update]
  # 管理者のみアクセス可能なアクションを指定
  before_action :admin_user,     only: :destroy
  
  # 新規ユーザー登録フォームを表示
  def new
    @user = User.new
  end
  
  # 新規ユーザーを作成
  def create
    @user = User.new(user_params)
    if @user.save
      # session[:user_id] = @user.id # ユーザー作成後、自動的にログイン
      log_in @user
      session[:new_registration] = true  # 新規登録時のフラグ
      redirect_to edit_user_path(@user), notice: '新規登録が完了しました。プロフィールを編集してください。'
      # redirect_to @user, notice: '新規登録が完了しました。'
    else
      render :new
    end
  end
  
  # ユーザー詳細ページを表示
  def show
    @user = User.find(params[:id])
  end
  
  private
  
  # Strong Parametersを使用してパラメータを制限
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
  
  # ログインしていない場合、ログインページにリダイレクト
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
  
  # 正しいユーザーかどうかを確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
  
  # 管理者かどうかを確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end