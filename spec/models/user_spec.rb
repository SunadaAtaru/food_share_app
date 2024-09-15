# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(username: "ExampleUser", email: "user@example.com", password: "password", password_confirmation: "password")
  end

  subject { @user }

  # バリデーションのテスト
  describe 'Validations' do
    it { should respond_to(:username) }
    it { should respond_to(:email) }
    it { should respond_to(:password_digest) }

    it { should be_valid }

    # 名前（username）が空の場合
    describe "when username is not present" do
      before { @user.username = " " }
      it { should_not be_valid }
    end

    # メールが空の場合
    describe "when email is not present" do
      before { @user.email = " " }
      it { should_not be_valid }
    end

    # 名前が長すぎる場合
    describe "when username is too long" do
      before { @user.username = "a" * 51 }
      it { should_not be_valid }
    end

    # 無効なメールフォーマットの場合
    describe "when email format is invalid" do
      it "should be invalid" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).not_to be_valid
        end
      end
    end

    # 有効なメールフォーマットの場合
    describe "when email format is valid" do
      it "should be valid" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end

    # メールが既に使われている場合
    describe "when email address is already taken" do
      before do
        user_with_same_email = @user.dup
        user_with_same_email.email = @user.email.upcase
        user_with_same_email.save
      end
      it { should_not be_valid }
    end

    # メールの大文字小文字の違いを保存する場合
    describe "email address with mixed case" do
      let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

      it "should be saved as all lower-case" do
        @user.email = mixed_case_email
        @user.save
        expect(@user.reload.email).to eq mixed_case_email.downcase
      end
    end

    # パスワードが空の場合
    describe "when password is not present" do
      before do
        @user = User.new(username: "ExampleUser", email: "user@example.com",
                         password: " ", password_confirmation: " ")
      end
      it { should_not be_valid }
    end

    # パスワードと確認が一致しない場合
    describe "when password doesn't match confirmation" do
      before { @user.password_confirmation = "mismatch" }
      it { should_not be_valid }
    end

    # パスワードが短すぎる場合
    describe "with a password that's too short" do
      before { @user.password = @user.password_confirmation = "a" * 5 }
      it { should be_invalid }
    end
  end
end
