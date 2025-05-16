class ChangeRoleTypeInUsers < ActiveRecord::Migration[7.1]
  def up
    # First, remove the default value
    change_column_default :users, :role, nil

    # Convert existing string roles to integers
    execute <<-SQL
      UPDATE users 
      SET role = CASE role 
        WHEN 'user' THEN '0'
        WHEN 'editor' THEN '1'
        WHEN 'admin' THEN '2'
        ELSE '0'
      END;
    SQL

    # Then change the column type
    execute <<-SQL
      ALTER TABLE users 
      ALTER COLUMN role TYPE integer 
      USING (role::integer);
    SQL

    # Set the new default value
    change_column_default :users, :role, 0
  end

  def down
    # Remove the default value
    change_column_default :users, :role, nil

    # Convert integers back to strings
    execute <<-SQL
      UPDATE users 
      SET role = CASE role::integer
        WHEN 0 THEN 'user'
        WHEN 1 THEN 'editor'
        WHEN 2 THEN 'admin'
        ELSE 'user'
      END;
    SQL

    # Change column type back to string
    change_column :users, :role, :string

    # Set the default value back
    change_column_default :users, :role, 'user'
  end
end 