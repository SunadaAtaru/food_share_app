# app/helpers/sessions_helper.rb
module SessionsHelper
  # ユーザーをログイン状態にする
  # @param [User] user ログインするユーザーオブジェクト
  def log_in(user)
    session[:user_id] = user.id  # セッションにユーザーIDを保存
  end

  # ユーザーのセッションを永続的にする
  # クッキーにユーザーIDとトークンを保存してユーザーを記憶する
  def remember(user)
    user.remember  # ユーザーモデルの `remember` メソッドを呼び出し、トークンを生成・保存
    cookies.permanent.signed[:user_id] = user.id  # 永続的なクッキーに署名付きユーザーIDを保存
    cookies.permanent[:remember_token] = user.remember_token  # 永続的なクッキーにリメンバートークンを保存
  end

  # 現在ログインしているユーザーを返す（いない場合はnil）
  # @return [User, nil] 現在のユーザーまたはnil
  def current_user
    # インスタンス変数 @current_user がすでに定義されている場合（つまり初回呼び出し以降）、
    # その値を返してメソッドを終了。定義されていなければ次の処理を実行する。
    return @current_user if instance_variable_defined?(:@current_user)

    if (user_id = session[:user_id]) # セッションにユーザーIDがある場合
      @current_user ||= User.find_by(id: user_id)  # セッションのユーザーIDに対応するユーザーを取得し、インスタンス変数に保存
    # セッションにユーザーIDがない場合、クッキーから取得
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)  # クッキーのユーザーIDに対応するユーザーを取得
      # クッキーに保存されたトークンがユーザーのトークンと一致するか確認
      if user && user.authenticated?(cookies[:remember_token])
        log_in user  # クッキーが有効であれば、ユーザーをログイン状態にする
        @current_user = user  # 現在のユーザーをインスタンス変数に保存
      end
    end
  end

  # ユーザーがログインしているかどうかを返す
  # @return [Boolean] ログイン状態
  def logged_in?
    !current_user.nil?  # `current_user` が存在する場合に true を返す
  end

  # 永続的セッションを破棄する
  # クッキーに保存されているユーザーIDとトークンを削除
  def forget(user)
    user.forget  # ユーザーモデルの `forget` メソッドを呼び出してトークンを無効化
    cookies.delete(:user_id)  # クッキーからユーザーIDを削除
    cookies.delete(:remember_token)  # クッキーからリメンバートークンを削除
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)  # 永続的セッションを削除
    session.delete(:user_id)  # セッションからユーザーIDを削除
    @current_user = nil  # 現在のユーザーをクリア
  end

  # ログインしているユーザーが引数として渡されたユーザーと一致するかを確認するメソッド
  # @param [User] user チェックするユーザーオブジェクト
  # @return [Boolean] 現在のユーザーと一致するか
  def current_user?(user)
    current_user == user  # 現在のユーザーと引数のユーザーが同じかどうかをチェック
  end
end
