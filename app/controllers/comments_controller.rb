class CommentsController < ApplicationController
  before_action :require_user

  def create
    @question = Question.find params[:question_id]
    @comment = @question.comments.new(comment_params)
    @comment.creator = current_user

    respond_to do |format|
      format.html do
        if @comment.save
          flash[:success] = 'Your comment has been created.'
          redirect_to @question
        else
          render 'questions/show'
        end
      end

      format.js {render layout: false}
    end
  end

  def vote
    comment = Comment.find(params[:id])
    vote = Vote.new(voteable: comment, creator: current_user, vote: params[:vote])

    if vote.valid?
      if comment.check_vote(current_user).nil?
        vote.save
        comment.counter(params[:vote])
      else
        comment.change_vote(params[:vote])
      end
    end

    respond_to do |format|
      format.html do
        flash[:error] = "You can't Vote on your own question" if !vote.valid?
        redirect_to :back
      end

      format.json { render json: [comment, vote] }
    end
  end

  def best_answer
    comment = Comment.find(params[:id])
    question = comment.question
    
    if question.creator == current_user
      comment.update(answer: true)
      question.update(answered: true)
    else
      access_denied
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.json
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
