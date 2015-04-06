class SessionsController < ApplicationController

  def create
    user = params[:email].to_s.match(/@/) ? User.find_by(email: params[:email]) :
    User.find_by(username: params[:email])

    if user && user.authenticate(params[:password])
      log_in user
      params[:remember_me].nil? ? forget(user) : remember(user)
      flash[:success] = 'You are now logged in.'
      redirect_back_or user
    else
      flash.now[:error] = 'Email / Username or Password is incorrect, please try again'
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'You are now logged out'
    redirect_to root_path
  end
end
