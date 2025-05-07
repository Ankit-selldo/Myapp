class BlogController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy]
  before_action :require_editor_or_admin, except: [:index, :show]

  def index
    @blog_posts = BlogPost.published.recent.includes(:author)
    @blog_posts = @blog_posts.page(params[:page]).per(10) if defined?(Kaminari)
  end

  def show
    unless @blog_post.published? || (authenticated? && (current_user.admin? || current_user.editor?))
      redirect_to blog_index_path, alert: "This post is not available."
    end
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.author = Current.user

    if @blog_post.save
      redirect_to blog_path(@blog_post), notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_post_modification
  end

  def update
    authorize_post_modification
    
    if @blog_post.update(blog_post_params)
      redirect_to blog_path(@blog_post), notice: "Blog post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_post_modification
    @blog_post.destroy
    redirect_to blog_index_path, notice: "Blog post was successfully deleted."
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find_by!(slug: params[:title])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :content, :status, :featured_image)
  end

  def require_editor_or_admin
    unless authenticated? && (Current.user.admin? || Current.user.editor?)
      redirect_to blog_index_path, alert: "You are not authorized to perform this action."
    end
  end

  def authorize_post_modification
    unless Current.user.admin? || (Current.user.editor? && @blog_post.author == Current.user)
      redirect_to blog_index_path, alert: "You are not authorized to modify this post."
    end
  end
end
