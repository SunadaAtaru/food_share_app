# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # app/controllers/sessions_controller.rb
  def new
    if logged_in?
      redirect_to user_path(current_user) # ログイン済みユーザーを自分のページへリダイレクト
    else
      # render 'new' # ログインフォームを表示
      # return
      # render 'new' を削除
      # なにも書かない（暗黙的にnewテンプレートがレンダリングされます）
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)  # フォームから送信されたメールアドレスでユーザーを検索
    if user && user.authenticate(params[:session][:password])  # ユーザーが存在し、パスワードが正しければ
      if user.activated?  # アカウントが有効化されているかをチェック
        log_in user  # ログイン処理
        remember user  # "remember me" チェックがあれば、セッション永続化処理
        # redirect_to user, notice: 'ログインに成功しました。'  # ログイン後にユーザー詳細ページにリダイレクト
        flash[:success] = 'ログインに成功しました。'
        redirect_to user_path(user)

      else
        flash[:warning] = "アカウントが有効化されていません。メールを確認してください。"  # アカウントが有効化されていない場合の警告メッセージ
        redirect_to root_url  # ルートURLにリダイレクト
      end
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません。'  # ログイン失敗時のエラーメッセージ
      render 'new'  # 再度ログインフォームを表示
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, notice: 'ログアウトしました。'
  end
end
