class RemoveDuplicateProductsWithoutImages < ActiveRecord::Migration[7.1]
  def up
    # Get all products without images
    products_without_images = Product.left_joins(:image_attachment)
                                   .where(active_storage_attachments: { id: nil })
                                   .group_by { |p| [p.name, p.category] }

    # Find and handle duplicates
    products_without_images.each do |key, products|
      next if products.length <= 1 # Skip if no duplicates

      name, category = key
      puts "Processing duplicates for #{name} (#{category})"

      # Keep the oldest product and merge others into it
      products_sorted = products.sort_by(&:created_at)
      product_to_keep = products_sorted.first
      products_to_remove = products_sorted[1..]

      products_to_remove.each do |product_to_remove|
        # Get all variants from both products
        existing_variants = product_to_keep.product_variants
        variants_to_move = product_to_remove.product_variants

        # For each variant in the product to remove
        variants_to_move.each do |variant_to_move|
          # Find matching variant in the product to keep
          existing_variant = existing_variants.find_by(size: variant_to_move.size, color: variant_to_move.color)
          
          if existing_variant
            # If matching variant exists, update its inventory count
            existing_variant.update_column(
              :inventory_count, 
              existing_variant.inventory_count + variant_to_move.inventory_count
            )
            # Delete the duplicate variant
            variant_to_move.destroy
          else
            # If no matching variant exists, move it to the product to keep
            variant_to_move.update_column(:product_id, product_to_keep.id)
          end
        end

        # Delete the duplicate product
        product_to_remove.destroy
        puts "  Removed duplicate product ID: #{product_to_remove.id}"
      end
    end
  end

  def down
    # This migration cannot be reversed
    raise ActiveRecord::IrreversibleMigration
  end
end 