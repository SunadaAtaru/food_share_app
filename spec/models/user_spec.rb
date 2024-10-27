require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(username: "ExampleUser", email: "user@example.com", password: "password", password_confirmation: "password")
  end

  subject { @user }

  # バリデーションのテスト
  describe 'バリデーション' do
    it 'usernameに応答すること' do
      should respond_to(:username)
    end
    it 'emailに応答すること' do
      should respond_to(:email)
    end
    it 'password_digestに応答すること' do
      should respond_to(:password_digest)
    end
    it '有効であること' do
      should be_valid
    end

    describe "ユーザー名が空の場合" do
      before { @user.username = " " }
      it '無効であること' do
        should_not be_valid
      end
    end

    describe "メールアドレスが空の場合" do
      before { @user.email = " " }
      it '無効であること' do
        should_not be_valid
      end
    end

    describe "ユーザー名が51文字以上の場合" do
      before { @user.username = "a" * 51 }
      it '無効であること' do
        should_not be_valid
      end
    end

    describe "メールアドレスのフォーマットが不正な場合" do
      it "無効であること" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).not_to be_valid
        end
      end
    end

    describe "メールアドレスのフォーマットが正しい場合" do
      it "有効であること" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end

    describe "メールアドレスが既に使用されている場合" do
      before do
        user_with_same_email = @user.dup
        user_with_same_email.email = @user.email.upcase
        user_with_same_email.save
      end
      it '無効であること' do
        should_not be_valid
      end
    end

    describe "メールアドレスの大文字小文字が混在する場合" do
      let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

      it "全て小文字で保存されること" do
        @user.email = mixed_case_email
        @user.save
        expect(@user.reload.email).to eq mixed_case_email.downcase
      end
    end

    describe "パスワードが空の場合" do
      before do
        @user = User.new(username: "ExampleUser", email: "user@example.com",
                        password: " ", password_confirmation: " ")
      end
      it '無効であること' do
        should_not be_valid
      end
    end

    describe "パスワードと確認用パスワードが一致しない場合" do
      before { @user.password_confirmation = "mismatch" }
      it '無効であること' do
        should_not be_valid
      end
    end

    describe "パスワードが5文字以下の場合" do
      before { @user.password = @user.password_confirmation = "a" * 5 }
      it '無効であること' do
        should be_invalid
      end
    end
  end

  # 前回提案した追加のテストも日本語化して追加可能です
end