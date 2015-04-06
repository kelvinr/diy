class EmailVerificationsController < ApplicationController

  def edit
    user = User.find_by email: params[:email]
    if user && !user.verified? && user.authenticated?(:verification, params[:id])
      user.verify
      log_in user
      flash[:success] = 'Your email has been verified!'
      redirect_to user
    else
      flash[:error] = 'Invalid activation link.'
      redirect_to root_path
    end
  end
end
