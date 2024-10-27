# spec/requests/sessions_spec.rb
require 'rails_helper'

# Sessionsコントローラーに対するリクエストスペック
RSpec.describe "Sessions", type: :request do

  # ユーザーを事前に作成
  let!(:user) { User.create(
    username: 'testuser', 
    email: 'test@example.com', 
    password: 'password', 
    password_confirmation: 'password',
    activated: true,  # これを追加
    activated_at: Time.zone.now  # これを追加
    ) }

  # GETリクエストのテスト: ログインページが正しく表示されるか確認
  describe "GET /login" do
    # 「ログインページへのアクセスが成功すること」
    it "returns a success response" do
      get login_path  # /loginへのGETリクエストを送信
      expect(response).to be_successful  # ステータスコード200 (成功)が返ってくることを期待
    end
  end

  # POSTリクエストのテスト: ログイン処理
  describe "POST /login" do
    
    # 有効な認証情報を使用してログインするテスト
    context "with valid credentials" do
      # 「ユーザーがログインし、ユーザーの詳細ページにリダイレクトされること」
      it "logs the user in and redirects to the user's show page" do
        # 正しいメールアドレスとパスワードを使ってPOSTリクエストを送信
        post login_path, params: { session: { email: user.email, password: 'password' } }
        
        # ログイン後にユーザーのshowページにリダイレクトされることを確認
        expect(response).to redirect_to(user_path(user))

        # リダイレクト先のページを取得し、表示内容を確認
        follow_redirect!
        expect(response.body).to include('ログインに成功しました。')

        # セッションに正しいユーザーIDが設定されているか確認
        expect(session[:user_id]).to eq(user.id)
      end
    end

    # 無効な認証情報を使用してログインするテスト
    context "with invalid credentials" do
      # 「エラーメッセージとともにログインページが再表示されること」
      it "re-renders the login page with an error" do
        # 誤ったパスワードでPOSTリクエストを送信
        post login_path, params: { session: { email: user.email, password: 'wrongpassword' } }
        
        # ログイン失敗時でもステータス200 (成功)が返され、再度ログインページが表示される
        expect(response).to be_successful

        # エラーメッセージが表示されることを確認
        expect(response.body).to include('メールアドレスまたはパスワードが正しくありません。')

        # セッションにユーザーIDが設定されていないことを確認（ログイン失敗）
        expect(session[:user_id]).to be_nil
      end
    end

    # 存在しないメールアドレスを使用してログインするテスト
    context "with non-existent email" do
      # 「エラーメッセージとともにログインページが再表示されること」
      it "re-renders the login page with an error" do
        # 存在しないメールアドレスでPOSTリクエストを送信
        post login_path, params: { session: { email: "nonexistent@example.com", password: 'password' } }
        
        # ステータス200が返され、ログインページが再度表示されることを確認
        expect(response).to be_successful

        # エラーメッセージが表示されることを確認
        expect(response.body).to include('メールアドレスまたはパスワードが正しくありません。')

        # セッションが設定されていないことを確認（ログイン失敗）
        expect(session[:user_id]).to be_nil
      end
    end

    # 既にログインしているユーザーが再度ログインページにアクセスしようとするテスト
    context "when already logged in" do
      before do
        # ログイン処理を事前に行う
        post login_path, params: { session: { email: user.email, password: 'password' } }
      end
      
      # 「ログイン済みユーザーがログインページにアクセスしようとした場合、リダイレクトされること」
      it "redirects logged-in users trying to access the login page" do
        # ログイン後に再度ログインページにアクセス
        get login_path

        # ユーザーのshowページにリダイレクトされることを確認
        expect(response).to redirect_to(user_path(user))
      end
    end
  end

  # DELETEリクエストのテスト: ログアウト処理
  describe "DELETE /logout" do
    before do
      # 事前にログインしておく
      post login_path, params: { session: { email: user.email, password: 'password' } }
    end
    
    # 「ユーザーがログアウトし、ルートパスにリダイレクトされること」
    it "logs the user out and redirects to the root path" do
      # DELETEリクエストを使ってログアウト
      delete logout_path
      
      # ログアウト後、ルートパスにリダイレクトされることを確認
      expect(response).to redirect_to(root_path)

      # リダイレクト先のページを取得し、表示内容を確認
      follow_redirect!
      expect(response.body).to include('ログアウトしました。')

      # セッションがクリアされ、ログインしていない状態であることを確認
      expect(session[:user_id]).to be_nil
    end
  end

  # アカウントが有効化されていないユーザーのログイン拒否テスト
  describe "User login", type: :request do
    before do
      # 有効化されていないユーザーを作成
      @user = create(:user, activated: false, activated_at: nil)
    end

    # 「アカウントが有効化されていないユーザーのログインを許可しないこと」
    it "does not allow login for unactivated users" do
      # 有効化されていないユーザーでログインを試みる
      post login_path, params: { session: { email: @user.email, password: @user.password } }
      
      # ログインが拒否され、セッションにユーザーIDが設定されないことを確認
      expect(session[:user_id]).to be_nil
    end
  end
end
