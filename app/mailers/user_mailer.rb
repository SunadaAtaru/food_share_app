# ユーザー関連のメール送信を担当するメイラークラス
class UserMailer < ApplicationMailer
  # アカウント有効化メールを送信するメソッド
  # @param user アカウント有効化メールを送信するユーザーオブジェクト
  def account_activation(user)
    @user = user  # メールテンプレートで使用するユーザー情報をインスタンス変数に設定
    mail to: user.email, subject: "Account activation"  # メールの宛先とタイトルを指定して送信
  end
 
  # パスワードリセットメールを送信するメソッド
  # @param user パスワードリセットメールを送信するユーザーオブジェクト
   def password_reset(user)
     @user = user  # メールテンプレートで使用するユーザー情報をインスタンス変数に設定
     mail to: user.email, subject: "Password reset"  # メールの宛先とタイトルを指定して送信
   end
 end