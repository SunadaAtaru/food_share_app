# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
本番環境のDBは、postgresql

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper  # セッション関連のヘルパーメソッドを含める

  private

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
end

# app/helpers/sessions_helper.rb
module SessionsHelper
  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end

# app/helpers/sessions_helper.rb
module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper

  helper_method :current_user, :logged_in?

  private

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
end

feature/authorization


<!-- app/views/layouts/_flash_messages.html.erb --><!-- Railsデフォルトスタイルの場合 -->
<% flash.each do |message_type, message| %>
  <div class="flash-message <%= message_type %>">
    <%= message %>
  </div>
<% end %>

<!-- Bootstrapを使用する場合 -->
<% flash.each do |message_type, message| %>
  <div class="alert alert-<%= message_type %> alert-dismissible fade show" role="alert">
    <%= message %>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
<% end %>

class User < ApplicationRecord
  # ユーザーが保存される前にメールアドレスをすべて小文字に変換
  before_save :downcase_email
  # ユーザー作成前に、有効化用トークンとダイジェストを生成
  before_create :create_activation_digest  

<%# app/views/sessions/new.html.erb %>
<div class="row justify-content-center">
  <div class="col-md-6">
    <h1 class="h3 mb-3">ログイン</h1>
    <%= render 'form' %>
  </div>
</div>


<%# app/views/sessions/_form.html.erb %>
<%= form_with(scope: :session, url: login_path) do |form| %>
  <div class="mb-3">
    <%= form.label :email, class: "form-label" %>
    <%= form.email_field :email, class: "form-control", required: true %>
    <div class="invalid-feedback">
      メールアドレスを入力してください
    </div>
  </div>

<!-- 残りのフォーム要素 -->
<% end %>

ActionView::Template::Error (undefined method `errors' for nil:NilClass):
    1: <!-- app/views/shared/_error_messages.html.erb -->
    2: <% if user.errors.any? %>
    3:   <div id="error_explanation" class="alert alert-danger w-100 mb-0">
    4:     <div class="container">
    5:       <h2 class="h5 mb-2">

    
    
<%# セッション（ログイン）フォーム %>
<%= form_with(scope: :session, url: login_path) do |form| %>
  <%= form.email_field :email %>     # params[:session][:email]
  <%= form.password_field :password %> # params[:session][:password]
<% end %>

<%# ユーザー登録フォーム %>
<%= form_with(model: @user) do |form| %>
  <%= form.email_field :email %>     # params[:user][:email]
  <%= form.password_field :password %> # params[:user][:password]
<% end %>


<!-- <%# app/views/sessions/_form.html.erb %> -->
<% flash.each do |message_type, message| %>
  <div class="alert alert-<%= message_type %>">
    <%= message %>
  </div>
<% end %>

<%= form_with(scope: :session, url: login_path) do |form| %>
<!-- 既存のフォームコード -->
<% end %>

