require 'open-uri'

namespace :products do
  desc 'Attach sample images to products'
  task attach_images: :environment do
    # Sample image URLs from Unsplash for each category
    category_images = {
      'hoodies' => [
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800',
        'https://images.unsplash.com/photo-1578681994506-b8f463449011?w=800',
        'https://images.unsplash.com/photo-1614495039153-e9cd13240469?w=800',
        'https://images.unsplash.com/photo-1579572331145-5e53b299c64e?w=800',
        'https://images.unsplash.com/photo-1611911813383-67769b37a149?w=800'
      ],
      'tshirts' => [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800',
        'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800'
      ],
      'shirts' => [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800',
        'https://images.unsplash.com/photo-1598032895397-b9472444bf93?w=800',
        'https://images.unsplash.com/photo-1621072156002-e2fccdc0b176?w=800'
      ],
      'jeans' => [
        'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800',
        'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=800',
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800'
      ],
      'shorts' => [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800',
        'https://images.unsplash.com/photo-1617952236317-0bd127407984?w=800',
        'https://images.unsplash.com/photo-1617952729916-cf71d6d9a4f1?w=800'
      ],
      'caps' => [
        'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=800',
        'https://images.unsplash.com/photo-1620327467532-6ebaca6273ed?w=800',
        'https://images.unsplash.com/photo-1534215754734-18e55d13e346?w=800'
      ],
      'sweaters' => [
        'https://images.unsplash.com/photo-1631541909061-71e349d1a193?w=800',
        'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=800',
        'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?w=800'
      ]
    }

    # Variant images for each color
    color_images = {
      'Black' => 'https://images.unsplash.com/photo-1618354691792-d1d42acfd860?w=800',
      'Grey' => 'https://images.unsplash.com/photo-1618354691438-25bc04584c23?w=800',
      'Navy' => 'https://images.unsplash.com/photo-1618354691229-88d47f285158?w=800',
      'White' => 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800',
      'Brown' => 'https://images.unsplash.com/photo-1618354691972-15de2a9f9502?w=800',
      'Red' => 'https://images.unsplash.com/photo-1618354691551-44de113f0164?w=800',
      'Blue' => 'https://images.unsplash.com/photo-1618354691249-18772bbac3a5?w=800',
      'Light Blue' => 'https://images.unsplash.com/photo-1618354691321-e851c56960d2?w=800',
      'Pink' => 'https://images.unsplash.com/photo-1618354691534-c1c8f837d7b8?w=800',
      'Khaki' => 'https://images.unsplash.com/photo-1618354691793-ab7cd0c7a729?w=800',
      'Burgundy' => 'https://images.unsplash.com/photo-1618354691892-c1c8f837d7b9?w=800'
    }

    Product.find_each do |product|
      puts "Processing #{product.name}..."

      # Attach main product image
      begin
        main_image_url = category_images[product.category].sample
        main_image = URI.open(main_image_url)
        product.image.attach(
          io: main_image,
          filename: "#{product.name.parameterize}.jpg",
          content_type: 'image/jpeg'
        )
        puts "  Attached main image"
      rescue => e
        puts "  Error attaching main image: #{e.message}"
      end

      # Attach additional product images
      begin
        additional_images = category_images[product.category].sample(2)
        additional_images.each do |image_url|
          additional_image = URI.open(image_url)
          product.images.attach(
            io: additional_image,
            filename: "#{product.name.parameterize}-#{SecureRandom.hex(4)}.jpg",
            content_type: 'image/jpeg'
          )
        end
        puts "  Attached additional images"
      rescue => e
        puts "  Error attaching additional images: #{e.message}"
      end

      # Attach variant images
      product.product_variants.each do |variant|
        begin
          if color_images[variant.color]
            variant_image = URI.open(color_images[variant.color])
            variant.image.attach(
              io: variant_image,
              filename: "#{variant.sku.downcase}.jpg",
              content_type: 'image/jpeg'
            )
            puts "  Attached image for variant #{variant.sku}"
          end
        rescue => e
          puts "  Error attaching variant image: #{e.message}"
        end
      end

      puts "Completed processing #{product.name}"
    end

    puts "Finished attaching all images!"
  end
end 