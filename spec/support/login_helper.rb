# spec/support/system_test_helper.rb
# spec/support/login_helper.rb
module LoginHelper
  def login_as(user)
    visit login_path
    fill_in 'メールアドレス', with: user.email    # 'Email' から変更
    fill_in 'パスワード', with: user.password     # 'Password' から変更
    click_button 'ログイン'
  end

  def logout
    click_link 'ログアウト'
  end
end

