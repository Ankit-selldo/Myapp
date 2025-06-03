namespace :admin do
  desc 'Create or update admin user'
  task create: :environment do
    admin_email = 'ankit.godara@sell.do'
    admin_password = '123456'  # You can change this password

    # First, ensure any existing admin is found
    admin = User.find_by(email: admin_email)
    
    if admin
      # Update existing admin
      admin.update!(
        password: admin_password,
        password_confirmation: admin_password,
        role: :admin,
        name: 'Ankit Godara',
        email: admin_email
      )
      puts "Admin user updated with new password"
    else
      # Create new admin
      admin = User.new(
        email: admin_email,
        password: admin_password,
        password_confirmation: admin_password,
        role: :admin,
        name: 'Ankit Godara'
      )
      
      if admin.save
        puts "Admin user created successfully"
      else
        puts "Failed to create admin user:"
        puts admin.errors.full_messages
      end
    end

    if admin.persisted?
      puts "\nAdmin login credentials:"
      puts "Email: #{admin_email}"
      puts "Password: #{admin_password}"
    end
  end
end 