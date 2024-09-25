# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # app/controllers/sessions_controller.rb
  def new
    if logged_in?
      redirect_to user_path(current_user) # ログイン済みユーザーを自分のページへリダイレクト
    else
      render 'new' # ログインフォームを表示
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)  # フォームから送信されたメールアドレスでユーザーを検索
    if user && user.authenticate(params[:session][:password])  # ユーザーが存在し、パスワードが正しければ
      log_in user  # ログイン処理
      remember user  # "remember me" チェックがあれば、セッション永続化処理
      redirect_to user, notice: 'ログインに成功しました。'  # ログイン後にユーザー詳細ページにリダイレクト
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません。'  # ログイン失敗時のメッセージ
      render 'new'  # 再度ログインフォームを表示
    end
  end
  
  
  
 

  
  def destroy
    log_out if logged_in?
    redirect_to root_url, notice: 'ログアウトしました。'
  end
end

# def create
#   user = User.find_by(email: params[:session][:email].downcase)
#   if user && user.authenticate(params[:session][:password])
#     log_in user 
#     remember user
#     if session[:new_registration]
#       session.delete(:new_registration)  # フラグを削除
#       redirect_to user, notice: '新規登録が完了しました。'
#     else
#       redirect_to user, notice: 'ログインに成功しました。'
#     end
#   else
#     flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません。'
#     render 'new'
#   end
# end
