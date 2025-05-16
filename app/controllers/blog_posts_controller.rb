class BlogPostsController < ApplicationController
  def index
    @featured_posts = BlogPost.published.featured.limit(2)
    
    @blog_posts = BlogPost.published
    @blog_posts = @blog_posts.by_category(params[:category]) if params[:category].present?
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @blog_posts = @blog_posts.where("title ILIKE ? OR content ILIKE ?", search_term, search_term)
    end
    
    @blog_posts = @blog_posts.order(published_at: :desc).page(params[:page]).per(9)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("blog_posts_results", 
          partial: "blog_posts/posts_grid", 
          locals: { blog_posts: @blog_posts })
      end
    end
  end

  def show
    @blog_post = BlogPost.find(params[:id])
    @related_posts = @blog_post.related_posts
  end
end 