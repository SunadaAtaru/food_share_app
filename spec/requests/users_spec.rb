# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:valid_attributes) {
    { username: "testuser", email: "test@example.com", password: "password", password_confirmation: "password" }
  }

  let(:invalid_attributes) {
    { username: "", email: "invalid", password: "short", password_confirmation: "mismatch" }
  }

  describe "GET /new" do
    it "returns a success response" do
      get new_user_path
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post users_path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post users_path, params: { user: valid_attributes }
        expect(response).to redirect_to(User.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post users_path, params: { user: invalid_attributes }
        }.to change(User, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post users_path, params: { user: invalid_attributes }
        expect(response).to be_successful
      end

      it "renders errors on the form" do
        post users_path, params: { user: invalid_attributes }
        expect(response.body).to include("can&#39;t be blank") # 実際のエラーメッセージに置き換えてください
      end
      it "renders errors on the form" do
        post users_path, params: { user: invalid_attributes }
        expect(response.body).to include("error_explanation") # エラーメッセージが表示されることを確認
      end
      
    end
  end

  describe "GET /show" do
    let!(:user) { User.create! valid_attributes }

    it "returns a success response" do
      get user_path(user)
      expect(response).to be_successful
    end
  end
end
