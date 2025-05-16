require "open-uri"

images = {
  "Jeans" => "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80",
  "Lowers" => "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=400&q=80",
  "Shirt" => "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80",
  "T-Shirt" => "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80",
  "Jacket" => "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80",
  # Add more product names and image URLs as needed
}

Product.find_each do |product|
  url = images[product.name]
  next unless url

  file = URI.open(url)
  product.image.attach(io: file, filename: "#{product.name.downcase}.jpg", content_type: "image/jpeg")
  puts "Attached image for #{product.name}"
end 