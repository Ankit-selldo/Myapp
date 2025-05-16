class RemoveDuplicateAthleticShorts < ActiveRecord::Migration[7.1]
  def up
    # Find the duplicate products
    older_product = Product.find_by(id: 13)
    newer_product = Product.find_by(id: 30)

    if older_product && newer_product
      # Get all variants from both products
      older_variants = older_product.product_variants
      newer_variants = newer_product.product_variants

      # For each variant in the newer product
      newer_variants.each do |newer_variant|
        # Find matching variant in older product
        older_variant = older_variants.find_by(size: newer_variant.size, color: newer_variant.color)
        
        if older_variant
          # If matching variant exists, update its inventory count
          older_variant.update_column(
            :inventory_count, 
            older_variant.inventory_count + newer_variant.inventory_count
          )
          # Delete the newer variant
          newer_variant.destroy
        else
          # If no matching variant exists, move it to the older product
          newer_variant.update_column(:product_id, older_product.id)
        end
      end

      # Delete the newer duplicate product
      newer_product.destroy
    end
  end

  def down
    # This migration cannot be reversed
    raise ActiveRecord::IrreversibleMigration
  end
end 