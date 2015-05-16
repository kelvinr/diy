class QuestionsController < ApplicationController
  before_action :require_user, only: [:create, :vote]
  before_action :find_question, only: [:show, :vote, :answered]
  before_action :require_verified, only: [:create]

  def index
    if logged_in?
      count ||= 0
      ids ||= current_user.subs.ids
      count += Question.where(category_id: ids).size
      @questions = Question.where(category_id: ids).limit(Question::PER_PAGE).offset(params[:offset]).sort_by{|x| x.vote_count}.reverse
      @pages = (count.to_f / Question::PER_PAGE).ceil
    else
      @pages = (Question.all.size.to_f / Question::PER_PAGE).ceil
      @questions = Question.limit(Question::PER_PAGE).offset(params[:offset]).sort_by{|x| x.vote_count}.reverse
    end
  end

  def show
    @comment = Comment.new

    @comments = @question.comments.limit(Comment::PER_PAGE).offset(params[:offset]).sort_by{|x| x.vote_count}.reverse
    @pages = (@question.comments.size.to_f / Comment::PER_PAGE).ceil
  end

  def create
    @category = Category.find(params[:category_id])
    @question = @category.questions.new(question_params)
    @question.creator = current_user

    respond_to do |format|
      format.html do
        if @question.save
          flash[:success] = "Your question has been created"
          redirect_to @question.category
        else
          render 'categories/show'
        end
      end

      format.js {render layout: false}
    end
  end

  def vote
    vote = Vote.new(voteable: @question, creator: current_user, vote: params[:vote])

    if vote.valid?
      if @question.check_vote(current_user).nil?
        vote.save
        @question.counter(params[:vote])
      else
        @question.change_vote(params[:vote])
      end
    end

    respond_to do |format|
      format.html do
        flash[:error] = "You can't Vote on your own question" if !vote.valid?
        redirect_to :back
      end

      format.json {render json: [@question, vote]}
    end
  end

private

  def find_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
