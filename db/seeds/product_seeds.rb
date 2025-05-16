require 'open-uri'

# Product data for each category
PRODUCTS_DATA = {
  hoodies: [
    {
      name: "Urban Street Hoodie",
      description: "Premium cotton blend hoodie with modern street-style design",
      price: 2499.99,
      image_url: "https://images.unsplash.com/photo-1509942774463-acf339cf87d5?w=800",
      variants: [
        { size: "S", color: "Black", inventory: 25, price_adjustment: 0 },
        { size: "M", color: "Black", inventory: 30, price_adjustment: 0 },
        { size: "L", color: "Black", inventory: 30, price_adjustment: 0 },
        { size: "XL", color: "Black", inventory: 20, price_adjustment: 100 }
      ]
    },
    {
      name: "Eco-Friendly Zip Hoodie",
      description: "Made from recycled materials with minimal environmental impact",
      price: 2999.99,
      image_url: "https://images.unsplash.com/photo-1578681994506-b8f463449011?w=800",
      variants: [
        { size: "S", color: "Grey", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Grey", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Grey", inventory: 25, price_adjustment: 0 }
      ]
    },
    {
      name: "Athletic Performance Hoodie",
      description: "Moisture-wicking fabric perfect for workouts",
      price: 3499.99,
      image_url: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800",
      variants: [
        { size: "S", color: "Navy", inventory: 15, price_adjustment: 0 },
        { size: "M", color: "Navy", inventory: 20, price_adjustment: 0 },
        { size: "L", color: "Navy", inventory: 20, price_adjustment: 0 }
      ]
    }
  ],
  
  tshirts: [
    {
      name: "Classic Crew Neck",
      description: "Timeless design with premium cotton comfort",
      price: 999.99,
      image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800",
      variants: [
        { size: "S", color: "White", inventory: 30, price_adjustment: 0 },
        { size: "M", color: "White", inventory: 35, price_adjustment: 0 },
        { size: "L", color: "White", inventory: 35, price_adjustment: 0 }
      ]
    },
    {
      name: "Graphic Art Tee",
      description: "Unique artistic design printed on soft cotton",
      price: 1299.99,
      image_url: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800",
      variants: [
        { size: "S", color: "Black", inventory: 25, price_adjustment: 0 },
        { size: "M", color: "Black", inventory: 30, price_adjustment: 0 },
        { size: "L", color: "Black", inventory: 30, price_adjustment: 0 }
      ]
    }
  ],
  
  shirts: [
    {
      name: "Premium Cotton Dress Shirt",
      description: "Elegant dress shirt perfect for formal occasions",
      price: 1999.99,
      image_url: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800",
      variants: [
        { size: "S", color: "White", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "White", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "White", inventory: 25, price_adjustment: 0 }
      ]
    },
    {
      name: "Casual Oxford Shirt",
      description: "Comfortable oxford cotton for everyday wear",
      price: 1799.99,
      image_url: "https://images.unsplash.com/photo-1598032895397-b9472444bf93?w=800",
      variants: [
        { size: "S", color: "Blue", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Blue", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Blue", inventory: 25, price_adjustment: 0 }
      ]
    }
  ],
  
  jeans: [
    {
      name: "Classic Slim Fit Jeans",
      description: "Timeless slim fit design in premium denim",
      price: 2999.99,
      image_url: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=800",
      variants: [
        { size: "30", color: "Blue", inventory: 20, price_adjustment: 0 },
        { size: "32", color: "Blue", inventory: 25, price_adjustment: 0 },
        { size: "34", color: "Blue", inventory: 25, price_adjustment: 0 }
      ]
    },
    {
      name: "Stretch Comfort Jeans",
      description: "High-stretch denim for maximum comfort",
      price: 3299.99,
      image_url: "https://images.unsplash.com/photo-1475178626620-a4d074967452?w=800",
      variants: [
        { size: "30", color: "Dark Blue", inventory: 20, price_adjustment: 0 },
        { size: "32", color: "Dark Blue", inventory: 25, price_adjustment: 0 },
        { size: "34", color: "Dark Blue", inventory: 25, price_adjustment: 0 }
      ]
    }
  ],
  
  shorts: [
    {
      name: "Summer Casual Shorts",
      description: "Lightweight cotton shorts for summer comfort",
      price: 1499.99,
      image_url: "https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800",
      variants: [
        { size: "S", color: "Khaki", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Khaki", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Khaki", inventory: 25, price_adjustment: 0 }
      ]
    },
    {
      name: "Athletic Performance Shorts",
      description: "Quick-dry fabric perfect for workouts",
      price: 1699.99,
      image_url: "https://images.unsplash.com/photo-1617952236317-0bd127407984?w=800",
      variants: [
        { size: "S", color: "Black", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Black", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Black", inventory: 25, price_adjustment: 0 }
      ]
    }
  ],
  
  caps: [
    {
      name: "Classic Baseball Cap",
      description: "Traditional 6-panel design with adjustable strap",
      price: 799.99,
      image_url: "https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=800",
      variants: [
        { size: "One Size", color: "Navy", inventory: 30, price_adjustment: 0 },
        { size: "One Size", color: "Black", inventory: 30, price_adjustment: 0 }
      ]
    },
    {
      name: "Premium Snapback Cap",
      description: "Modern snapback with embroidered design",
      price: 999.99,
      image_url: "https://images.unsplash.com/photo-1620327467532-6ebaca6273ed?w=800",
      variants: [
        { size: "One Size", color: "Black", inventory: 25, price_adjustment: 0 },
        { size: "One Size", color: "Grey", inventory: 25, price_adjustment: 0 }
      ]
    }
  ],
  
  sweaters: [
    {
      name: "Merino Wool Sweater",
      description: "Premium merino wool for ultimate comfort",
      price: 3499.99,
      image_url: "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800",
      variants: [
        { size: "S", color: "Grey", inventory: 15, price_adjustment: 0 },
        { size: "M", color: "Grey", inventory: 20, price_adjustment: 0 },
        { size: "L", color: "Grey", inventory: 20, price_adjustment: 0 }
      ]
    },
    {
      name: "Cashmere Blend V-Neck",
      description: "Luxurious cashmere blend for elegant style",
      price: 4499.99,
      image_url: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800",
      variants: [
        { size: "S", color: "Navy", inventory: 10, price_adjustment: 0 },
        { size: "M", color: "Navy", inventory: 15, price_adjustment: 0 },
        { size: "L", color: "Navy", inventory: 15, price_adjustment: 0 }
      ]
    }
  ]
}

# Add jackets to the PRODUCTS_DATA hash
PRODUCTS_DATA.merge!({
  jackets: [
    {
      name: "Classic Leather Jacket",
      description: "Timeless leather jacket crafted from premium genuine leather. Features a sleek design with zippered pockets and quilted shoulders.",
      price: 5999.99,
      image_url: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800",
      variants: [
        { size: "S", color: "Black", inventory: 15, price_adjustment: 0 },
        { size: "M", color: "Black", inventory: 20, price_adjustment: 0 },
        { size: "L", color: "Black", inventory: 20, price_adjustment: 0 },
        { size: "XL", color: "Black", inventory: 15, price_adjustment: 200 }
      ]
    },
    {
      name: "Denim Trucker Jacket",
      description: "Classic denim jacket with a modern fit. Perfect for layering and casual wear.",
      price: 2999.99,
      image_url: "https://images.unsplash.com/photo-1495105787522-5334e3ffa0ef?w=800",
      variants: [
        { size: "S", color: "Blue", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Blue", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Blue", inventory: 25, price_adjustment: 0 },
        { size: "XL", color: "Blue", inventory: 15, price_adjustment: 100 }
      ]
    },
    {
      name: "Bomber Jacket",
      description: "Stylish bomber jacket with ribbed cuffs and hem. Water-resistant and perfect for spring/fall weather.",
      price: 3499.99,
      image_url: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800",
      variants: [
        { size: "S", color: "Olive", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Olive", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Olive", inventory: 25, price_adjustment: 0 },
        { size: "XL", color: "Olive", inventory: 15, price_adjustment: 100 }
      ]
    },
    {
      name: "Quilted Winter Jacket",
      description: "Warm and cozy quilted jacket with premium insulation. Perfect for cold weather.",
      price: 4499.99,
      image_url: "https://images.unsplash.com/photo-1544923246-77307dd654cb?w=800",
      variants: [
        { size: "S", color: "Navy", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Navy", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Navy", inventory: 25, price_adjustment: 0 },
        { size: "XL", color: "Navy", inventory: 15, price_adjustment: 150 }
      ]
    },
    {
      name: "Windbreaker Sport Jacket",
      description: "Lightweight and water-resistant windbreaker perfect for outdoor activities and sports.",
      price: 2499.99,
      image_url: "https://images.unsplash.com/photo-1604025677169-6b07c4b5d3c3?w=800",
      variants: [
        { size: "S", color: "Red", inventory: 20, price_adjustment: 0 },
        { size: "M", color: "Red", inventory: 25, price_adjustment: 0 },
        { size: "L", color: "Red", inventory: 25, price_adjustment: 0 },
        { size: "XL", color: "Red", inventory: 15, price_adjustment: 100 }
      ]
    }
  ]
})

# Find or create admin user
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.name = 'Admin'
  user.password = 'admin123'
  user.role = 'admin'
end

# Create products for each category
PRODUCTS_DATA.each do |category, products|
  products.each do |product_data|
    # Skip if product already exists
    next if Product.exists?(name: product_data[:name])

    # Create the product
    product = Product.create!(
      name: product_data[:name],
      description: product_data[:description],
      price: product_data[:price],
      category: category.to_s,
      user: admin,
      inventory_count: product_data[:variants].sum { |v| v[:inventory] }
    )

    # Attach image
    begin
      image = URI.open(product_data[:image_url])
      product.image.attach(
        io: image,
        filename: "#{product.name.parameterize}.jpg",
        content_type: 'image/jpeg'
      )
      puts "Attached image for #{product.name}"
    rescue => e
      puts "Error attaching image for #{product.name}: #{e.message}"
    end

    # Create variants
    product_data[:variants].each do |variant_data|
      # Generate a unique SKU
      base = product.name.parameterize[0..3].upcase
      sku = loop do
        potential_sku = "#{base}-#{variant_data[:size]}-#{variant_data[:color][0..2].upcase}-#{SecureRandom.hex(2).upcase}"
        break potential_sku unless ProductVariant.exists?(sku: potential_sku)
      end

      product.product_variants.create!(
        size: variant_data[:size],
        color: variant_data[:color],
        inventory_count: variant_data[:inventory],
        price_adjustment: variant_data[:price_adjustment],
        sku: sku
      )
    end

    puts "Created #{product.name} with #{product.product_variants.count} variants"
  end
end

puts "Finished creating products!" 