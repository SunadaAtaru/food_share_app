class AccountActivationsController < ApplicationController

  # アカウント有効化の処理を行うeditアクション
  def edit
    # URLに含まれるemailパラメータを使ってユーザーを検索する
    user = User.find_by(email: params[:email])

    # ユーザーが存在し、有効化されておらず、認証トークンが一致する場合
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate  # ユーザーを有効化するメソッドを呼び出す
      log_in user  # ログインさせる（ログインヘルパーを使用）
      flash[:success] = "アカウントが有効化されました！"  # 成功メッセージをフラッシュに設定
      redirect_to user  # ユーザーの詳細ページにリダイレクト
    else
      flash[:danger] = "無効な有効化リンクです。"  # リンクが無効な場合、エラーメッセージを表示
      redirect_to root_url  # ルートページにリダイレクト
    end
  end

end
