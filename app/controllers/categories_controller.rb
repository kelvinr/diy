class CategoriesController < ApplicationController
  before_action :require_user, only: [:new, :create, :sub, :unsub]
  before_action :find_category, only: [:show, :sub, :unsub]

  def index
    if logged_in?
      user_subs
      @categories = Category.where.not(id: user_subs).limit(Category::PER_PAGE).offset(params[:offset])
    else
      @categories = Category.limit(Category::PER_PAGE).offset(params[:offset])
    end
    @pages = (Category.all.size.to_f / Category::PER_PAGE).ceil
  end

  def show
    @question = Question.new
    @questions = @category.questions.limit(Question::PER_PAGE).offset(params[:offset])
    @pages = (@category.questions.size.to_f / Question::PER_PAGE).ceil
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.create(params.require(:category).permit(:name, :description))

    if @category.save
      flash[:success] = 'Your category has been created.'
      redirect_to @category
    else
      render :new
    end
  end

  def sub
    if !current_user.subs.include? @category
      current_user.subs << @category
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render json: @category }
      end
    end
  end

  def unsub
    if current_user.subs.include? @category
      current_user.subs.delete @category
      respond_to do |format|
        format.html {redirect_to :back}
        format.json { render json: @category }
      end
    end
  end

private

  def user_subs
    @user_subs ||= Category.where(id: current_user.subs.ids)
  end

  def find_category
    @category = Category.find params[:id]
  end
end
