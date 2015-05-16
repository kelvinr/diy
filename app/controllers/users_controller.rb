class UsersController < ApplicationController
  before_action :find_user, only: [:show, :edit, :update, :avatar, :update_avatar, :delete_avatar]
  before_action :require_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]
  before_action :user_activity, only: :show
  after_action :uploads_cleaner, only: :update_avatar

  def show
    @show_msgs = true if @user == current_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)

    if @user.save
      flash[:success] = 'Your profile has been created'
      @user.send_verification_email
      log_in @user
      store_user
      redirect_to root_path
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      store_user
      flash[:success] = 'Your profile has been updated.'
      redirect_to @user
    else
      render :edit
    end
  end

  def avatar
    @s3_bucket = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}-${filename}",
                                          success_action_status: "201",
                                          acl: "public-read-write")
  end

  def update_avatar
    if params[:user] && params[:user][:avatar_url].include?('https://diyavatar')
      @user.delete_avatar
      @user.update(avatar_url: params[:user][:avatar_url])

      flash[:success] = 'Your avatar has been updated.'
      redirect_to @user
    else
      flash.now[:error] = 'Sorry there was an issue uploading your image. Please try again.'
      render :avatar
    end
  end

  def delete_avatar
    @user.delete_avatar
    @user.update(avatar_url: nil)
    redirect_to @user
  end

private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :avatar_url)
  end

  def uploads_cleaner
    extras = params[:uploads].split
    extras.each do |key|
      S3_BUCKET.objects[key].delete if @user.avatar_url.match(/[^"]+/, 35).to_s != key
    end
  end

  def find_user
    @user = User.find params[:id]
  end

  def store_user
    params[:remember_me].nil? ? forget(@user) : remember(@user)
  end

  def user_activity
    case params[:tab]
      when "comments"
        @activity = Comment.where(creator: @user).limit(Comment::PER_PAGE).offset(params[:offset])
        @pages = (@user.comments.size.to_f / Comment::PER_PAGE).ceil
      when "recieved"
        @activity = Message.where(recipient_id: @user.id).limit(Message::PER_PAGE).offset(params[:offset])
        @pages = (@user.recieved_messages.size.to_f / Message::PER_PAGE).ceil
      when "sent"
        @activity = Message.where(sender_id: @user.id).limit(Message::PER_PAGE).offset(params[:offset])
        @pages = (@user.sent_messages.size.to_f / Message::PER_PAGE).ceil
      when nil
        @activity = Question.where(user_id: @user.id).limit(Question::PER_PAGE).offset(params[:offset])
        @pages = (@user.questions.size.to_f / Question::PER_PAGE).ceil
    end
  end
end
