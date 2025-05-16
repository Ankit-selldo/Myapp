class ChangeDiscountTypeToInteger < ActiveRecord::Migration[8.0]
  def up
    # Create a temporary column
    add_column :discounts, :discount_type_int, :integer

    # Update the values
    execute <<-SQL
      UPDATE discounts 
      SET discount_type_int = CASE 
        WHEN discount_type = 'percentage' THEN 0 
        WHEN discount_type = 'fixed_amount' THEN 1 
      END
    SQL

    # Remove the old column
    remove_column :discounts, :discount_type

    # Rename the new column
    rename_column :discounts, :discount_type_int, :discount_type

    # Add a not null constraint
    change_column_null :discounts, :discount_type, false
  end

  def down
    # Create a temporary column
    add_column :discounts, :discount_type_str, :string

    # Update the values
    execute <<-SQL
      UPDATE discounts 
      SET discount_type_str = CASE 
        WHEN discount_type = 0 THEN 'percentage' 
        WHEN discount_type = 1 THEN 'fixed_amount' 
      END
    SQL

    # Remove the old column
    remove_column :discounts, :discount_type

    # Rename the new column
    rename_column :discounts, :discount_type_str, :discount_type

    # Add a not null constraint
    change_column_null :discounts, :discount_type, false
  end
end 