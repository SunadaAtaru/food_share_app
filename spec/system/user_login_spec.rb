# spec/system/user_login_spec.rb
require 'rails_helper'

RSpec.describe "User Login", type: :system do
  let!(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  it "allows a user to log in" do
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "ログイン"

    expect(page).to have_content("ログインに成功しました。")
    expect(page).to have_content(user.username)
  end

  it "does not allow a user to log in with invalid credentials" do
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpassword"
    click_button "ログイン"

    expect(page).to have_content("メールアドレスまたはパスワードが正しくありません。")
  end

  it "allows a user to log out" do
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "ログイン"
    click_link "ログアウト"

    expect(page).to have_content("ログアウトしました。")
  end
end
