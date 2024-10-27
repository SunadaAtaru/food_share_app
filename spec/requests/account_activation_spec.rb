require 'rails_helper'

RSpec.describe "Account activation", type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    # メールアドレスを使用する前にデータベースをクリーンアップ
    User.delete_all  # この行を追加
    @user = create(:user, activated: false, activated_at: nil)
    @user.activation_token = User.new_token
    @user.update_attribute(:activation_digest, User.digest(@user.activation_token))
  end


    # ...
    it "有効化メールを送信する" do
      # デバッグ用の出力
      test_params = { 
        user: { 
          username: "Example User",
          # email: "user@example.com",
          email: "test_#{Time.current.to_i}@example.com",  # 一意のメールアドレスを生成
          password: "password",
          password_confirmation: "password" 
        }
      }
      puts "Test params: #{test_params.inspect}"
    
      expect {
        post users_path, params: test_params
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
      # 追加のデバッグ情報
    if User.last
      puts "Created user: #{User.last.inspect}"
      puts "Activation email sent: #{ActionMailer::Base.deliveries.last.inspect}"
    else
      puts "User creation failed"
    end
    
      # メールの内容を確認
      # expect(ActionMailer::Base.deliveries.last.to).to eq(["user@example.com"])
      # テストパラメータのメールアドレスと比較
      expect(ActionMailer::Base.deliveries.last.to).to eq([test_params[:user][:email]])  
      expect(ActionMailer::Base.deliveries.last.subject).to eq("アカウントの有効化")
    end 
    # ...
  

  it "有効なトークンでユーザーを有効化する" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    @user.reload
    expect(@user.activated?).to be_truthy
  end

  it "無効なトークンではユーザーを有効化しない" do
    get edit_account_activation_path("invalid_token", email: @user.email)
    @user.reload
    expect(@user.activated?).to be_falsey
  end

  it "無効なメールアドレスではユーザーを有効化しない" do
    get edit_account_activation_path(@user.activation_token, email: "wrong@example.com")
    @user.reload
    expect(@user.activated?).to be_falsey
  end

  it "期限切れのトークンではユーザーを有効化しない" do
    @user.update_attribute(:created_at, 3.days.ago)  # 3日経過後に設定
    expect(@user.activation_token_valid?).to be_falsey
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    @user.reload
    expect(@user.activated?).to be_falsey
  end
end
