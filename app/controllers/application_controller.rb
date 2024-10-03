class ApplicationController < ActionController::Base
  # CSRF（クロスサイトリクエストフォージェリ）攻撃から保護する
  protect_from_forgery with: :exception
  
  # SessionsHelperモジュールをインクルードして、全コントローラでそのメソッドを使用可能にする
  include SessionsHelper
  
  private  # 以下のメソッドはこのクラス内でのみ使用する

  # ログインを要求するメソッド
  def require_login
    # ユーザーがログインしていない場合の処理
    unless logged_in?
      store_location  # アクセスしようとしたURLを保存
      flash[:alert] = "You must be logged in to access this section"  # フラッシュメッセージを表示
      redirect_to login_path  # ログインページにリダイレクト
    end
  end

  # アクセスしようとしたURLをセッションに保存する
  def store_location
    # GETリクエストのみを対象とする
    session[:forwarding_url] = request.original_url if request.get?
  end

  # 保存されたURLまたはデフォルトのURLにリダイレクトする
  def redirect_back_or(default)
    # セッションに保存されているURLがあればそこにリダイレクト、なければデフォルトのURLにリダイレクト
    redirect_to(session[:forwarding_url] || default)
    # リダイレクト後に保存していたURLを削除する
    session.delete(:forwarding_url)
  end
end
