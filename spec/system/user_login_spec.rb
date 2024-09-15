# # spec/system/user_authentication_spec.rb
require 'rails_helper' # Railsの環境をロードする

RSpec.describe 'UserLogins', type: :system do
  let!(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password') }

  it 'allows a user to log in with valid credentials' do
    visit login_path # ログインページに移動

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'
    click_button 'ログイン'

    expect(page).to have_content('ログインに成功しました。')
    expect(page).to have_content('testuser')
  end

  it 'displays errors when login fails' do
    visit login_path

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'wrongpassword'
    click_button 'ログイン'

    expect(page).to have_content('メールアドレスまたはパスワードが正しくありません。')
  end

  it 'allows a logged-in user to log out' do
    # まずログインする
    visit login_path
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'
    click_button 'ログイン'

    # ログアウトリンクをクリック
    click_link 'ログアウト'

    # ログアウト後の確認
    expect(page).to have_content('ログアウトしました。')
    expect(page).not_to have_content('testuser') # ログイン中のユーザー名が表示されていないことを確認
  end
end
