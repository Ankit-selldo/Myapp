class AddOtpVerificationFields < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp, :string unless column_exists?(:users, :otp)
    add_column :users, :otp_sent_at, :datetime unless column_exists?(:users, :otp_sent_at)
  end
end 