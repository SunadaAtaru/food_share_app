# spec/system/user_activation_spec.rb
require 'rails_helper'

RSpec.describe 'UserActivation', type: :system do
  include ActiveJob::TestHelper

  before do
    perform_enqueued_jobs do
      ActionMailer::Base.deliveries.clear
    end
  end

  describe 'アカウント有効化プロセス' do
    let(:user) { create(:user, activated: false) }

    it 'サインアップ時にアクティベーションメールが送信される' do
      visit signup_path
      
      # フィールド名を実際のラベルに合わせて修正
      fill_in 'user[username]', with: 'testuser'
      fill_in 'user[email]', with: 'test@example.com'
      fill_in 'user[password]', with: 'password'
      fill_in 'user[password_confirmation]', with: 'password'
      
      perform_enqueued_jobs do
        expect {
          click_button 'アカウント作成'
        }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
      
      expect(page).to have_content('メールを確認して、アカウントを有効化してください。')
    end

    it '有効化されていないアカウントではログインできない' do
      visit login_path
      # name属性を使用してフィールドを特定
      fill_in 'session[email]', with: user.email
      fill_in 'session[password]', with: 'password'
      click_button 'ログイン'

      expect(page).to have_content('アカウントが有効化されていません。メールを確認してください。')
    end

    it '有効化リンクをクリックするとアカウントが有効化される' do
      visit edit_account_activation_path(user.activation_token, email: user.email)
      expect(page).to have_content('アカウントが有効化されました。')
    end

    it '無効な有効化リンクではアカウントが有効化されない' do
      visit edit_account_activation_path('invalid_token', email: user.email)
      expect(page).to have_content('無効な有効化リンクです。')
    end

    it '期限切れの有効化トークンは無効' do
      user.update_attribute(:activation_digest, User.digest(User.new_token))
      visit edit_account_activation_path(user.activation_token, email: user.email)
      expect(page).to have_content('無効な有効化リンクです。')
    end

    # spec/system/user_activation_spec.rb
    describe 'アクティベーションメール' do
      it '正しい内容のメールが送信される' do
        perform_enqueued_jobs do
          mail = UserMailer.account_activation(user)
          expect(mail.to).to eq([user.email])
          expect(mail.subject).to eq('アカウントの有効化')
          
          # 本文をデコードして確認
          html_part = mail.html_part.body.decoded
          text_part = mail.text_part.body.decoded
          
          # HTML部分のチェック
          expect(html_part).to include('アカウントを有効化する')
          expect(html_part).to include(user.username)
          
          # テキスト部分のチェック
          expect(text_part).to include('アカウントを有効化')
          expect(text_part).to include(user.username)
        end
      end
    end
  end
end