require_relative '../config/environment'

# Get all hoodie products
hoodies = Product.where(category: 'hoodies')

# Get all image files from today
image_files = Dir.glob(Rails.root.join('storage', '*', '*', '*')).select do |file|
  File.mtime(file) > Time.now.beginning_of_day
end

puts "Found #{image_files.length} images from today"

# Attach each image to a hoodie
image_files.each_with_index do |file, index|
  hoodie = hoodies[index % hoodies.length]
  next unless hoodie

  begin
    # Open the file and create a blob
    File.open(file) do |io|
      filename = "hoodie_#{index + 1}.jpg"
      content_type = 'image/jpeg'
      
      # Attach as main image if none exists, otherwise add to images collection
      if !hoodie.image.attached?
        hoodie.image.attach(io: io, filename: filename, content_type: content_type)
        puts "Attached main image to #{hoodie.name}"
      else
        hoodie.images.attach(io: io, filename: filename, content_type: content_type)
        puts "Attached additional image to #{hoodie.name}"
      end
    end
  rescue => e
    puts "Error attaching image to #{hoodie.name}: #{e.message}"
  end
end

puts "Image attachment process completed!" 