class MessagesController < ApplicationController
  before_action :find_recipient
  before_action :require_user

  def new
    @message = Message.new
    if current_user == @user
      flash[:danger] = "You can't send a message to yourself"
      redirect_to :back
    end
  end

  def create
    @message = Message.create(message_params)
    @message.sender = current_user
    @message.recipient = @user

    if @message.save
      flash[:success] = 'Your message has been sent'
      redirect_to @user
    else
      render :new
    end
  end

private

  def message_params
    params.require(:message).permit(:subject, :body)
  end

  def find_recipient
    @user = User.find(params[:id])
  end
end
