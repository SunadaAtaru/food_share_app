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
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user 
      remember user
      redirect_to user, notice: 'ログインに成功しました。'
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません。'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, notice: 'ログアウトしました。'
  end
end
