# spec/system/user_sign_up_spec.rb
require 'rails_helper'

RSpec.describe "User Sign Up", type: :system do
  it "allows a user to sign up" do
    visit new_user_path
    fill_in "Username", with: "testuser"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign Up"

    save_and_open_page

    expect(page).to have_content("新規登録が完了しました。")
    expect(page).to have_content("testuser")
  end
end

