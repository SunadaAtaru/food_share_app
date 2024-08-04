# spec/requests/sessions_spec.rb
require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  describe "GET /login" do
    it "returns a success response" do
      get login_path
      expect(response).to be_successful
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "logs the user in and redirects to the user's show page" do
        post login_path, params: { session: { email: user.email, password: 'password' } }
        expect(response).to redirect_to(user_path(user))
        follow_redirect!
        expect(response.body).to include('ログインに成功しました。')
      end
    end

    context "with invalid credentials" do
      it "re-renders the login page with an error" do
        post login_path, params: { session: { email: user.email, password: 'wrongpassword' } }
        expect(response).to be_successful
        expect(response.body).to include('メールアドレスまたはパスワードが正しくありません。')
      end
    end
  end

  describe "DELETE /logout" do
    it "logs the user out and redirects to the root path" do
      get logout_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('ログアウトしました。')
    end
  end
end
