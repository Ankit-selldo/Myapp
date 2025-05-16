class FixDeviseEmailStructure < ActiveRecord::Migration[7.1]
  def up
    # Step 1: Handle the email column situation
    if column_exists?(:users, :email_address) && !column_exists?(:users, :email)
      rename_column :users, :email_address, :email
    elsif !column_exists?(:users, :email) && !column_exists?(:users, :email_address)
      add_column :users, :email, :string
    end

    # Step 2: Ensure the email column has the proper constraints
    change_column_null :users, :email, false
    
    # Step 3: Ensure proper indexing
    unless index_exists?(:users, :email, unique: true)
      add_index :users, :email, unique: true
    end

    # Step 4: Create user with specific credentials
    unless User.find_by(email: 'ankit.godara@sell.do')
      user = User.new(
        email: 'ankit.godara@sell.do',
        password: '123456',
        password_confirmation: '123456',
        name: 'Ankit',
        role: :admin  # Assuming you want to keep admin role
      )
      # Save without validations to bypass any potential validation issues
      user.save(validate: false)
      puts "\nUser created:"
      puts "Email: ankit.godara@sell.do"
      puts "Password: 123456"
    end
  end

  def down
    # This migration is not reversible due to potential data loss
    raise ActiveRecord::IrreversibleMigration
  end
end 