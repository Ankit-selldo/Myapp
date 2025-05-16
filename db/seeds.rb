# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'open-uri'

# Create admin user
admin = User.find_or_initialize_by(email: 'ankit.godara@sell.do')
admin.assign_attributes(
  password: '123456',
  role: :admin,
  name: 'Ankit Godara'
)
admin.save!

puts "Admin user created: #{admin.email} (Role: #{admin.role})"

# Hoodie products data
hoodies = [
  {
    name: 'Classic Brown Hoodie',
    description: 'Minimalist brown hoodie perfect for everyday wear. Features a comfortable fit and high-quality cotton blend material.',
    price: 2499.99,
    category: 'hoodies',
    featured: true
  },
  {
    name: 'GLOOMY Butterfly Hoodie',
    description: 'Dark green hoodie featuring a stunning butterfly design. Made from premium cotton with a relaxed fit.',
    price: 2999.99,
    category: 'hoodies',
    featured: true
  },
  {
    name: 'YIKES Flame Logo Hoodie',
    description: 'Grey streetwear hoodie with flame text design. Includes matching cap and premium cotton construction.',
    price: 2799.99,
    category: 'hoodies',
    featured: false
  },
  {
    name: 'Classic White Adidas Hoodie',
    description: 'Clean and classic white Adidas hoodie. Features the iconic Adidas logo and comfortable cotton blend.',
    price: 3499.99,
    category: 'hoodies',
    featured: true
  },
  {
    name: 'Skull Rose Hoodie',
    description: 'Bold yellow hoodie featuring a unique skull and rose design. Perfect for making a statement.',
    price: 2899.99,
    category: 'hoodies',
    featured: false
  }
]

# Additional products data
other_products = [
  # T-shirts
  {
    name: 'Classic White T-Shirt',
    description: 'Essential white t-shirt made from premium cotton. Perfect for everyday wear.',
    price: 999.99,
    category: 'tshirts',
    featured: true
  },
  {
    name: 'Graphic Print T-Shirt',
    description: 'Stylish graphic print t-shirt with modern design. 100% cotton material.',
    price: 1299.99,
    category: 'tshirts',
    featured: false
  },
  # Shirts
  {
    name: 'Oxford Blue Shirt',
    description: 'Classic Oxford shirt in light blue. Perfect for formal and casual occasions.',
    price: 1999.99,
    category: 'shirts',
    featured: true
  },
  {
    name: 'Checkered Casual Shirt',
    description: 'Casual checkered shirt in cotton blend fabric. Comfortable fit for daily wear.',
    price: 1799.99,
    category: 'shirts',
    featured: false
  },
  # Jeans
  {
    name: 'Classic Blue Denim',
    description: 'Classic blue denim jeans with comfortable stretch fit.',
    price: 2999.99,
    category: 'jeans',
    featured: true
  },
  {
    name: 'Black Slim Fit Jeans',
    description: 'Sleek black jeans in slim fit design. Premium denim material.',
    price: 3299.99,
    category: 'jeans',
    featured: false
  },
  # Shorts
  {
    name: 'Cargo Shorts',
    description: 'Practical cargo shorts with multiple pockets. Perfect for summer.',
    price: 1499.99,
    category: 'shorts',
    featured: true
  },
  {
    name: 'Athletic Shorts',
    description: 'Comfortable athletic shorts with moisture-wicking fabric.',
    price: 1299.99,
    category: 'shorts',
    featured: false
  },
  # Caps
  {
    name: 'Classic Baseball Cap',
    description: 'Traditional baseball cap with adjustable strap.',
    price: 799.99,
    category: 'caps',
    featured: true
  },
  {
    name: 'Snapback Cap',
    description: 'Modern snapback cap with embroidered design.',
    price: 999.99,
    category: 'caps',
    featured: false
  },
  # Sweaters
  {
    name: 'Wool Blend Sweater',
    description: 'Warm wool blend sweater perfect for winter.',
    price: 2499.99,
    category: 'sweaters',
    featured: true
  },
  {
    name: 'V-Neck Sweater',
    description: 'Classic v-neck sweater in soft cotton blend.',
    price: 2299.99,
    category: 'sweaters',
    featured: false
  }
]

# Create all products
[hoodies, other_products].flatten.each do |product_data|
  product = Product.create!(
    name: product_data[:name],
    description: product_data[:description],
    price: product_data[:price],
    category: product_data[:category],
    featured: product_data[:featured],
    user: admin,
    inventory_count: 0 # We'll use variant inventory instead
  )
  
  puts "Created #{product.name}"

  # Create variants for each product
  product.available_colors.each do |color|
    product.available_sizes.each do |size|
      # Add some random price adjustments for different sizes
      price_adjustment = if size.in?(['XS', 'S', '28', '30'])
        0
      elsif size.in?(['M', 'L', '32', '34'])
        100
      else
        200
      end

      ProductVariant.create!(
        product: product,
        size: size,
        color: color,
        inventory_count: rand(5..20),
        price_adjustment: price_adjustment,
        active: true
      )
    end
  end
  
  puts "Created variants for #{product.name}"
end

# Note: Images will need to be attached separately through the web interface
# or by using Active Storage's attach method with the actual image files

# Create sample users for blog authors
puts "Creating blog authors..."
fashion_editor = User.create!(
  name: "Sophie Anderson",
  email: "sophie@fashionstore.com",
  password: "password123",
  role: "editor"
)

sustainability_expert = User.create!(
  name: "Alex Rivera",
  email: "alex@fashionstore.com",
  password: "password123",
  role: "editor"
)

style_guru = User.create!(
  name: "Emma Chen",
  email: "emma@fashionstore.com",
  password: "password123",
  role: "editor"
)

# Attach avatars to authors
def attach_avatar(user, filename)
  avatar_path = Rails.root.join("app/assets/images/avatars/#{filename}")
  user.avatar.attach(io: File.open(avatar_path), filename: filename) if File.exist?(avatar_path)
end

attach_avatar(fashion_editor, "sophie.jpg")
attach_avatar(sustainability_expert, "alex.jpg")
attach_avatar(style_guru, "emma.jpg")

# Create sample blog posts
puts "Creating blog posts..."

# Style Guide Posts
post1 = BlogPost.create!(
  title: "10 Essential Pieces for Your Summer 2024 Wardrobe",
  content: ActionText::Content.new(<<~HTML
    <div class="prose">
      <p>As we step into Summer 2024, it's time to refresh your wardrobe with versatile pieces that combine style, comfort, and sustainability. Here are the must-have items that will keep you looking effortlessly chic all season long.</p>
      
      <h2>1. The Linen Blazer</h2>
      <p>A lightweight linen blazer in neutral tones is perfect for both office days and evening events. Look for sustainable linen options that keep you cool while maintaining a polished appearance.</p>
      
      <h2>2. High-Waisted Wide-Leg Trousers</h2>
      <p>Comfortable yet elegant, wide-leg trousers in breathable fabrics are this season's staple. Pair them with crop tops or tucked-in blouses for a balanced silhouette.</p>
      
      <h2>3. The Statement Midi Dress</h2>
      <p>Choose a dress with bold prints or vibrant colors that can transition from day to night with just a change of accessories.</p>
      
      <p>Stay tuned for our detailed styling guides for each piece!</p>
    </div>
  HTML
  ),
  author: style_guru,
  category: "Style Guide",
  status: "published",
  featured: true,
  meta_title: "Summer 2024 Wardrobe Essentials | Fashion Guide",
  meta_description: "Discover the 10 must-have pieces for your Summer 2024 wardrobe. From sustainable linen blazers to versatile dresses, create the perfect seasonal capsule.",
  published_at: 2.days.ago
)

# Sustainability Post
post2 = BlogPost.create!(
  title: "The Future of Sustainable Fashion: Beyond Organic Cotton",
  content: ActionText::Content.new(<<~HTML
    <div class="prose">
      <p>The fashion industry is witnessing a revolutionary shift towards sustainability, with innovations that go far beyond traditional organic materials.</p>
      
      <h2>Innovative Materials</h2>
      <p>From mushroom leather to recycled ocean plastics, discover how technology is creating eco-friendly fabrics that don't compromise on style or durability.</p>
      
      <h2>Circular Fashion Economy</h2>
      <p>Learn how brands are implementing take-back programs and designing for longevity to reduce fashion's environmental impact.</p>
      
      <h2>Consumer Impact</h2>
      <p>Your choices matter. Find out how small changes in shopping habits can contribute to a more sustainable fashion industry.</p>
    </div>
  HTML
  ),
  author: sustainability_expert,
  category: "Sustainability",
  status: "published",
  featured: true,
  meta_title: "Sustainable Fashion Innovation | Beyond Organic",
  meta_description: "Explore the latest innovations in sustainable fashion, from mushroom leather to circular economy initiatives. Learn how technology is shaping eco-friendly fashion.",
  published_at: 1.day.ago
)

# Lookbook Post
post3 = BlogPost.create!(
  title: "Spring/Summer 2024 Collection Lookbook: Urban Nature",
  content: ActionText::Content.new(<<~HTML
    <div class="prose">
      <p>Our latest collection bridges the gap between city life and natural elements, creating a harmonious blend of structured silhouettes and organic textures.</p>
      
      <h2>Dawn to Dusk</h2>
      <p>Versatile pieces that transition seamlessly from morning meetings to evening gatherings, featuring our signature sustainable fabrics.</p>
      
      <h2>Color Story</h2>
      <p>This season's palette draws inspiration from urban gardens: sage green, terracotta, and soft sky blues complement our classic neutral foundation.</p>
      
      <h2>Styling Tips</h2>
      <p>Discover creative ways to mix and match pieces from the collection for endless outfit possibilities.</p>
    </div>
  HTML
  ),
  author: fashion_editor,
  category: "Lookbook",
  status: "published",
  featured: false,
  meta_title: "SS24 Collection Lookbook | Urban Nature Theme",
  meta_description: "Explore our Spring/Summer 2024 collection lookbook featuring sustainable fashion with an urban nature theme. See the latest styles and styling tips.",
  published_at: 3.days.ago
)

# Behind the Scenes Post
post4 = BlogPost.create!(
  title: "Crafting Sustainable Luxury: Our Design Process",
  content: ActionText::Content.new(<<~HTML
    <div class="prose">
      <p>Take a journey with us as we reveal the intricate process of creating sustainable luxury pieces that stand the test of time.</p>
      
      <h2>Material Selection</h2>
      <p>From selecting eco-certified fabrics to testing durability, every material is carefully chosen to meet our sustainability standards while ensuring premium quality.</p>
      
      <h2>Design & Development</h2>
      <p>Our designers work closely with artisans to create pieces that combine traditional craftsmanship with modern sustainability practices.</p>
      
      <h2>Quality Control</h2>
      <p>Each piece undergoes rigorous testing to ensure it meets our high standards for both quality and sustainability.</p>
    </div>
  HTML
  ),
  author: sustainability_expert,
  category: "Behind the Scenes",
  status: "published",
  featured: false,
  meta_title: "Sustainable Fashion Design Process | Behind the Scenes",
  meta_description: "Get an exclusive look at our sustainable luxury fashion design process, from material selection to final quality control.",
  published_at: 4.days.ago
)

# Fashion Tips Post
post5 = BlogPost.create!(
  title: "Mastering the Art of Capsule Wardrobe",
  content: ActionText::Content.new(<<~HTML
    <div class="prose">
      <p>Create a versatile and sustainable wardrobe that maximizes style while minimizing environmental impact.</p>
      
      <h2>The Basics</h2>
      <p>Start with high-quality, timeless pieces in neutral colors that can be mixed and matched effortlessly.</p>
      
      <h2>Seasonal Additions</h2>
      <p>Learn how to thoughtfully incorporate trend pieces without compromising your wardrobe's sustainability.</p>
      
      <h2>Maintenance Tips</h2>
      <p>Extend the life of your clothing with proper care and storage techniques.</p>
    </div>
  HTML
  ),
  author: style_guru,
  category: "Fashion Tips",
  status: "published",
  featured: false,
  meta_title: "Create a Sustainable Capsule Wardrobe | Fashion Guide",
  meta_description: "Learn how to build and maintain a sustainable capsule wardrobe with our expert tips on selecting, styling, and caring for your clothes.",
  published_at: 5.days.ago
)

# Attach featured images to blog posts
def attach_blog_image(post, filename)
  image_path = Rails.root.join("app/assets/images/blog/#{filename}")
  post.featured_image.attach(io: File.open(image_path), filename: filename) if File.exist?(image_path)
end

attach_blog_image(post1, "summer-essentials.jpg")
attach_blog_image(post2, "sustainable-fashion.jpg")
attach_blog_image(post3, "lookbook-spring.jpg")
attach_blog_image(post4, "behind-scenes.jpg")
attach_blog_image(post5, "capsule-wardrobe.jpg")

puts "Seed data created successfully!"
