class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  private

  def require_login
    unless logged_in?
      store_location
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  
end
