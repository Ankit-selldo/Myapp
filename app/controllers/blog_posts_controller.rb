class BlogPostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @posts = BlogPost.published
                    .includes(:author)
                    .with_rich_text_content
                    .with_attached_featured_image
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(12)
    
    @featured_posts = BlogPost.published.featured.limit(3)

    respond_to do |format|
      format.html
      format.json { render json: @posts }
    end
  rescue StandardError => e
    Rails.logger.error "Error in blog posts index: #{e.message}\n#{e.backtrace.join("\n")}"
    flash.now[:alert] = "Error loading blog posts. Please try again later."
    @posts = BlogPost.none.page(1)
    @featured_posts = BlogPost.none
    render :index, status: :internal_server_error
  end

  def show
    unless @blog_post.published? || current_user&.admin?
      redirect_to blog_posts_path, alert: "This post is not available."
      return
    end

    @related_posts = @blog_post.related_posts.limit(3)
  rescue StandardError => e
    Rails.logger.error "Error showing blog post: #{e.message}"
    redirect_to blog_posts_path, alert: "Error loading blog post. Please try again later."
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = current_user.blog_posts.build(blog_post_params)

    if @blog_post.save
      redirect_to blog_post_path(@blog_post), notice: 'Blog post was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Error creating blog post: #{e.message}"
    flash.now[:alert] = "Error creating blog post. Please try again."
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to blog_post_path(@blog_post), notice: 'Blog post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Error updating blog post: #{e.message}"
    flash.now[:alert] = "Error updating blog post. Please try again."
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @blog_post.destroy
    redirect_to blog_posts_path, notice: 'Blog post was successfully deleted.'
  rescue StandardError => e
    Rails.logger.error "Error deleting blog post: #{e.message}"
    redirect_to blog_posts_path, alert: "Error deleting blog post. Please try again."
  end

  private

  def set_blog_post
    # Use params[:title] for slug lookup if present, otherwise use params[:id]
    slug_or_id = params[:title].presence || params[:id]
    
    @blog_post = BlogPost.includes(:author)
                        .with_rich_text_content
                        .with_attached_featured_image
                        .find_by!(slug: slug_or_id)
  rescue ActiveRecord::RecordNotFound
    redirect_to blog_posts_path, alert: "Blog post not found."
  end

  def blog_post_params
    params.require(:blog_post).permit(
      :title,
      :content,
      :category,
      :featured_image,
      :meta_title,
      :meta_description,
      :status,
      :featured
    )
  end

  def require_admin
    unless current_user&.admin?
      redirect_to blog_posts_path, alert: "You are not authorized to perform this action."
    end
  end
end 