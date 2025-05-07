class BlogController < ApplicationController
  def show
    @title = params[:title]
    # Add your blog post fetching logic here
  end
end
