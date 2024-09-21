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