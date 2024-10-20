class UserMailer < ApplicationMailer

  # アカウント有効化メールを送信する
  def account_activation(user)
    @user = user
    @user.activation_token = User.new_token  # メール内でトークンを使うために生成
    mail to: @user.email, subject: "アカウントの有効化"  # メール送信
  end

  # パスワードリセットメールを送信する
  def password_reset(user)
    @user = user
    @user.reset_token = User.new_token  # メール内でリセットトークンを使うために生成
    mail to: @user.email, subject: "パスワードのリセット"  # メール送信
  end

end
