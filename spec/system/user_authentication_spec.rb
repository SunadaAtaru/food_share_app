# spec/system/user_authentication_spec.rb
require 'rails_helper'

RSpec.describe 'UserAuthentication', type: :system do
  let!(:user) { User.create(
    username: 'testuser', 
    email: 'test@example.com', 
    password: 'password',
    password_confirmation: 'password',
    activated: true,
    activated_at: Time.zone.now
  ) }

  before do
    driven_by(:rack_test)
  end

  describe 'ログインプロセス' do
    it 'allows a user to log in with valid credentials' do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'password'
      click_button 'ログイン'

      expect(page).to have_content('ログインに成功しました。')
      expect(page).to have_content(user.username)
    end

    it 'displays errors when login fails' do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'wrongpassword'
      click_button 'ログイン'

      expect(page).to have_content('メールアドレスまたはパスワードが正しくありません。')
    end
  end
  
  describe 'ログアウトプロセス' do
    it 'allows a logged-in user to log out' do
      # まずログインする
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'password'
      click_button 'ログイン'
  
      # ログアウトする
      click_link 'ログアウト'
  
      # 1. ログアウト後のリダイレクト先を確認
      expect(current_path).to eq root_path  # リダイレクト先がroot_pathであることを確認
  
      # 2. フラッシュメッセージの確認
      expect(page).to have_content('ログアウトしました。')
  
      # 3. ログアウト後のUI状態を確認
      expect(page).not_to have_content(user.username)  # ユーザー名が表示されていない
      expect(page).to have_link('ログイン')           # ログインリンクが表示されている
      expect(page).not_to have_link('ログアウト')# ログアウトリンクが表示されていない
    end     
  end
  
  

  describe '未有効化ユーザーの制限' do
    let!(:unactivated_user) { User.create(
      username: 'unactivated',
      email: 'unactivated@example.com',
      password: 'password',
      password_confirmation: 'password',
      activated: false
    ) }

    it '有効化されていないユーザーはログインできない' do
      visit login_path
      fill_in 'Email', with: unactivated_user.email
      fill_in 'Password', with: 'password'
      click_button 'ログイン'

      expect(page).to have_content('アカウントが有効化されていません。')
    end
  end
end
