module ProductImageProcessable
  extend ActiveSupport::Concern

  included do
    has_one_attached :image do |attachable|
      attachable.variant :thumb, resize_to_fill: [56, 56]
      attachable.variant :medium, resize_to_fill: [200, 200]
    end
  end

  def process_image
    return unless image.attached?
    
    # Ensure image is processed in the background
    image.variant(:thumb).processed
    image.variant(:medium).processed
  end
end 