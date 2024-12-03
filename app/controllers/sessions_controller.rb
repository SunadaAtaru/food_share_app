# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController

  before_action :redirect_if_logged_in, only: [:new]
  
  def new
     if logged_in?  # ユーザーがログイン済みかチェック
       if current_user.activated?  # ログインユーザーのアカウントが有効化済みかチェック
          redirect_to user_path(current_user)  # 有効化済みならユーザーページへリダイレクト
       else
          flash[:warning] = "アカウントが有効化されていません。メールを確認してください。"  # 未有効化の警告メッセージ
          redirect_to root_url  # ルートページへリダイレクト
       end
     else
        # 未ログインの場合はログインフォーム(new.html.erb)を表示
     end
   end

  def create
    # raise
    user = User.find_by(email: params[:session][:email].downcase)  # フォームから送信されたメールアドレスでユーザーを検索
    if user && user.authenticate(params[:session][:password])  # ユーザーが存在し、パスワードが正しければ
      if user.activated?  # アカウントが有効化されているかをチェック
        log_in user  # ログイン処理
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)  # ユーザーの選択に応じてセッション永続化
        flash[:success] = 'ログインに成功しました。'
        redirect_to user_path(user)

      else
        flash[:warning] = "アカウントが有効化されていません。メールを確認してください。"  # アカウントが有効化されていない場合の警告メッセージ
        redirect_to root_url  # ルートURLにリダイレクト
      end
    else
      flash.now[:danger] = 'メールアドレスまたはパスワードが正しくありません' #ログイン失敗時のメッセージログイン失敗時のメッセージ
      render 'new'  # 再度ログインフォームを表示
    end
  end

  def destroy
    log_out
    flash[:success] = 'ログアウトしました'
    redirect_to root_url
  end

  private

  def redirect_if_logged_in
    if logged_in?
      redirect_to root_url
      flash[:info] = "すでにログインしています"
    end
  end
end
