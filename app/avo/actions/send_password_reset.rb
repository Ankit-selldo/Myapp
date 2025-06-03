class Avo::Actions::SendPasswordReset < Avo::BaseAction
  self.name = "Send password reset"
  self.visible = -> do
    true
  end

  def handle(**args)
    records.each do |record|
      record.generate_password_reset_token!
    end

    succeed "Successfully sent password reset instructions to #{records.count} #{'user'.pluralize(records.count)}"
  end
end 