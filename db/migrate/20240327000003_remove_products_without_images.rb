class RemoveProductsWithoutImages < ActiveRecord::Migration[7.1]
  def up
    # Get all products without images
    products_to_remove = Product.left_joins(:image_attachment)
                              .where(active_storage_attachments: { id: nil })

    # Store the IDs for logging
    product_ids = products_to_remove.pluck(:id)

    puts "Removing #{product_ids.count} products without images..."

    # Remove associated variants first
    ProductVariant.where(product_id: product_ids).delete_all
    puts "Removed associated variants"

    # Remove the products
    products_to_remove.delete_all
    
    puts "Successfully removed products with IDs: #{product_ids.join(', ')}"
  end

  def down
    puts "This migration cannot be reversed - products cannot be restored"
    raise ActiveRecord::IrreversibleMigration
  end
end 