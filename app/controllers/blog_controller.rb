class BlogController < ApplicationController
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_admin_or_editor, only: [:new, :create, :edit, :update, :destroy]

  def index
    @featured_posts = BlogPost.featured.limit(3)
    @blog_posts = BlogPost.includes(:author)
                         .with_attached_featured_image
                         .not_featured
                         .search(params[:search])
                         .filter_by_category(params[:category])
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(12)
  end

  def show
    @related_posts = @blog_post.related_posts.limit(3)
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.author = current_user

    if @blog_post.save
      redirect_to blog_path(@blog_post), notice: 'Blog post was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to blog_path(@blog_post), notice: 'Blog post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to blogs_path, notice: 'Blog post was successfully deleted.'
  end

  def subscribe
    @subscriber = NewsletterSubscriber.new(email: params[:email])

    respond_to do |format|
      if @subscriber.save
        NewsletterMailer.welcome_email(@subscriber).deliver_later
        format.json { render json: [{ message: 'Successfully subscribed! Please check your email for a welcome message.' }], status: :ok }
        format.html { redirect_to blog_posts_path, notice: 'Successfully subscribed! Please check your email for a welcome message.' }
      else
        format.json { render json: [{ errors: @subscriber.errors.full_messages }], status: :unprocessable_entity }
        format.html { redirect_to blog_posts_path, alert: @subscriber.errors.full_messages.join(', ') }
      end
    end
  end

  def unsubscribe
    @subscriber = NewsletterSubscriber.find_by!(unsubscribe_token: params[:token])
    @subscriber.destroy

    redirect_to root_path, notice: 'You have been successfully unsubscribed from our newsletter.'
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Invalid unsubscribe link.'
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(
      :title, 
      :content, 
      :category, 
      :featured_image, 
      :meta_title, 
      :meta_description, 
      :featured,
      :published
    )
  end

  def check_admin_or_editor
    unless current_user&.admin? || current_user&.editor?
      redirect_to blogs_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
