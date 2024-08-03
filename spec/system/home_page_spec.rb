# spec/system/home_page_spec.rb
require 'rails_helper'

RSpec.describe "Home Page", type: :system do
  it "displays the welcome message" do
    visit root_path
    expect(page).to have_content("トップページ")
    expect(page).to have_content("ようこそ。")
  end
end
