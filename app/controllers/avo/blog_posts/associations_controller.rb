class Avo::BlogPosts::AssociationsController < Avo::AssociationsController
  # Override the index method to handle the custom association fetching and authorization
  def index
    if params[:related_name] == 'related_products'
      # Explicitly set up the related resource and authorization for this custom association
      @related_resource = Avo::Resources::Product
      @related_authorization = @related_resource.new(nil).authorize(current_user, @related_resource.model_class)

      # Fetch the parent BlogPost record using the find_record method from the resource
      @parent_record = current_resource.find_record(params[:id], current_user)

      # Fetch related products using the custom method on the BlogPost model
      # The authorize_with block on the field in the resource should handle filtering
      @records = @parent_record.related_products

      # Render Avo's default index view for associations
      render "avo/base/index"
    else
      # For other associations, fall back to Avo's default behavior
      super
    end
  end
end 