class ArticlesController < ApplicationController
  before_action :authenticate_admin!, except: [:index, :show]
  before_action :correct_admin, only: [:edit, :update, :destroy]
  before_action :is_published, only: [:show]

  def index
    if (params[:tag])
      @articles = Article.tagged_with(params[:tag]).order(created_at: :desc)
    else
      @articles = Article.all.order(created_at: :desc)
    end
  end

  def new
    @article = current_admin.articles.build
  end

  def edit
    @article = Article.friendly.find(params[:id])
  end

  def create
    @article = current_admin.articles.build(article_params)

    if @article.save
      flash[:notice] = "Article created successfully."
      redirect_to @article
    else
      flash[:alert] = "There was an issue submitting the article."
      render 'new'
    end
  end

  def show
    @article = Article.friendly.find(params[:id]) if Article.friendly.exists? params[:id]
    @previous = nil
    @next = nil

    @url = request.base_url + request.fullpath
    @encoded = URI.escape(@url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    if @article
      @title = URI.escape(@article.title, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      @subtitle = URI.escape(@article.subtitle, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

      id = @article.id.to_i - 1
      while (not @previous) and (id >= Article.first.id)
        @previous = Article.exists?(id) ? Article.find(id) : nil
        id = id - 1
      end
      id = @article.id.to_i + 1
      while (not @next) and (id <= Article.last.id)
        @next = Article.exists?(id) ? Article.find(id) : nil
        id = id + 1
      end
      if (not @next or not @previous)
        random = Article.limit(10).where.not(id: id).order("RANDOM()")
        @next = @next.nil? ? random.first : @next
        @previous = @previous.nil? ? random.second : @previous
      end
    else
      random = Article.limit(10).order("RANDOM()")
      @previous = random.first
      @next = random.second
    end
  end

  def update
    @article = Article.friendly.find(params[:id])

    if @article.update(article_params)
      flash[:notice] = "Article updated successfully."
      redirect_to @article
    else
      flash[:alert] = "There was an error updating the article."
      render 'edit'
    end
  end


  def destroy
    @article = Article.friendly.find(params[:id])
    @article.destroy
    flash[:notice] = "Article deleted successfully."
    redirect_to articles_path
  end

  private
  def article_params
    params.require(:article).permit(:title, :subtitle, :text, :image, :tag_list, :published)
  end

  # Confirms the correct admin.
  def correct_admin
    article = Article.friendly.find(params[:id])
    unless current_admin.id.to_i == article.admin.id.to_i
      flash[:alert] = "You don't have permission to perform this action."
      redirect_to(root_url)
    end
  end

  def is_published
    article = Article.friendly.find(params[:id])
    unless article.published or current_admin
      flash[:alert] = "You cannot access this article."
      redirect_to(root_url)
    end
  end
end
