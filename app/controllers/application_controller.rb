class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include UsersHelper

  helper_method :private_msg

  def current_vote
    @current_vote ||= Vote.find_by(user_id: current_user.id)
  end

  def search
    @categories = Category.search_db(params[:search_term])
    @questions = Question.search_db(params[:search_term])
    render :search if request.post? || request.get?
  end

  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget current_user
    session.delete(:user_id)
    @current_user = nil
  end

  def require_user
    unless logged_in?
      store_location
      flash[:error] = 'You must be logged in to do that'
      redirect_to login_path
    end
  end

  def wrong_path
    flash[:error] = 'There was an error.'
    redirect_to root_path
  end

  def access_denied
    flash[:error] = "You can't do that"
    redirect_to root_path
  end

  def private_msg(show, tab)
    access_denied if (tab == 'sent' || tab == 'recieved') && !show
  end

  def correct_user
    accesss_denied unless current_user == @user
  end

  def redirect_back_or(default)
    redirect_to session[:forwarding_url] || default
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
