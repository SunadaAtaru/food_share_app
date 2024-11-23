require 'rails_helper'  # これが必要

RSpec.describe "Home Page", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "基本的なページ内容" do
    before { visit root_path }

    it "アプリケーション名とメインメッセージを表示" do
      expect(page).to have_content("FoodShareApp")
      expect(page).to have_content("ようこそ、ふーどシェアアプリへ！")
    end

    it "サービスの説明文を表示" do
      expect(page).to have_content("食べ物を共有し、無駄をなくしましょう。")
      expect(page).to have_content("地域の人々と共有しましょう")
      expect(page).to have_content("新しい友達を作り")
    end
  end

  describe "ナビゲーション要素" do
    before { visit root_path }

    it "ヘッダーにナビゲーションリンクが存在" do
      within('header') do  # ヘッダー内の要素を特定
        expect(page).to have_link("ログイン")
        expect(page).to have_link("サインアップ")
      end
    end

    it "新規登録ボタンが適切な位置に表示" do
      within('main') do  # メインコンテンツ内の要素を特定
        expect(page).to have_link("新規登録")
      end
    end
  end

  describe "レイアウトとスタイル" do
    before { visit root_path }

    # it "必要なセクションが存在" do
    #   expect(page).to have_css('header')
    #   expect(page).to have_css('main')
    #   expect(page).to have_css('footer')
    # end

    # it "人気のカテゴリーセクションが表示" do
    #   expect(page).to have_content("人気のカテゴリー")
    # end
  end

  describe "リンクの機能" do
    before { visit root_path }

    it "ログインリンクが正しいパスを持つ" do
      expect(page).to have_link("ログイン", href: login_path)
    end

    it "サインアップリンクが正しいパスを持つ" do
      expect(page).to have_link("サインアップ", href: signup_path)
    end
  end

  # describe "レスポンシブ対応", js: true do
  #   before do
  #     driven_by(:selenium_chrome_headless)
  #     visit root_path
  #   end

  #   it "モバイルビューでメニューが適切に表示" do
  #     page.driver.browser.resize_to(375, 667) # モバイルサイズ
  #     expect(page).to have_css('.mobile-menu', visible: false)
  #   end
  # end
end