namespace :db do
  desc 'Seed products with images and variants'
  task seed_products: :environment do
    require Rails.root.join('db', 'seeds', 'product_seeds.rb')
  end
end 