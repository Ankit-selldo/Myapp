require_relative '../config/environment'
require 'base64'
require 'tempfile'

def create_temp_image_file(base64_data)
  temp_file = Tempfile.new(['image', '.jpg'])
  temp_file.binmode
  temp_file.write(Base64.decode64(base64_data))
  temp_file.rewind
  temp_file
end

# Get all hoodie products
hoodies = Product.where(category: 'hoodies')

# Attach images to specific products
hoodies.find_each do |hoodie|
  case hoodie.name
  when 'Classic Brown Hoodie'
    # Attach brown hoodie image
    hoodie.image.attach(
      io: File.open('tmp/brown_hoodie.jpg'),
      filename: 'brown_hoodie.jpg',
      content_type: 'image/jpeg'
    )
  when 'GLOOMY Butterfly Hoodie'
    # Attach GLOOMY hoodie image
    hoodie.image.attach(
      io: File.open('tmp/gloomy_hoodie.jpg'),
      filename: 'gloomy_hoodie.jpg',
      content_type: 'image/jpeg'
    )
  when 'YIKES Flame Logo Hoodie'
    # Attach YIKES hoodie image
    hoodie.image.attach(
      io: File.open('tmp/yikes_hoodie.jpg'),
      filename: 'yikes_hoodie.jpg',
      content_type: 'image/jpeg'
    )
  when 'Classic White Adidas Hoodie'
    # Attach white Adidas hoodie image
    hoodie.image.attach(
      io: File.open('tmp/white_adidas_hoodie.jpg'),
      filename: 'white_adidas_hoodie.jpg',
      content_type: 'image/jpeg'
    )
  when 'Skull Rose Hoodie'
    # Attach skull rose hoodie image
    hoodie.image.attach(
      io: File.open('tmp/skull_rose_hoodie.jpg'),
      filename: 'skull_rose_hoodie.jpg',
      content_type: 'image/jpeg'
    )
  end
  
  puts "Attached image to #{hoodie.name}"
rescue => e
  puts "Error attaching image to #{hoodie.name}: #{e.message}"
end

puts "Image attachment process completed!" 