# spec/system/user_sign_up_spec.rb
require 'rails_helper'

# RSpec.describe "User Sign Up", type: :system do
#   it "allows a user to sign up" do
#     visit new_user_path
#     fill_in "Username", with: "testuser"
#     fill_in "Email", with: "test@example.com"
#     fill_in "Password", with: "password"
#     fill_in "Password confirmation", with: "password"
#     click_button "Sign Up"

#     save_and_open_page

#     expect(page).to have_content("新規登録が完了しました。")
#     expect(page).to have_content("testuser")
#   end
# end

# spec/system/user_authentication_spec.rb
require 'rails_helper'

RSpec.describe 'UserSignups', type: :system do
  before do
    driven_by(:rack_test) # headless_chrome を使いたい場合は変更可能
  end

  it 'allows a user to sign up with valid information' do
    visit signup_path # サインアップページに移動

    fill_in 'Username', with: 'testuser'
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'

    click_button 'アカウント作成'

    expect(page).to have_content('新規登録が完了しました。')
    expect(page).to have_content('testuser') # ログイン後のユーザー名を確認
  end

  it 'displays errors when sign up fails' do
    visit signup_path

    fill_in 'Username', with: ''
    fill_in 'Email', with: 'invalidemail'
    fill_in 'Password', with: 'pass'
    fill_in 'Password confirmation', with: 'different'

    click_button 'アカウント作成'

    expect(page).to have_content("4 errors prohibited this user from being saved:")
    expect(page).to have_content("Username can't be blank")
    expect(page).to have_content("Email is invalid")
    expect(page).to have_content("Password is too short (minimum is 6 characters)")
    expect(page).to have_content("Password confirmation doesn't match Password")
  end
end
