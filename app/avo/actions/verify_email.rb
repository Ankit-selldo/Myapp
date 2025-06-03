class Avo::Actions::VerifyEmail < Avo::BaseAction
  self.name = "Verify email"
  self.visible = -> do
    true
  end

  def handle(**args)
    records.each do |record|
      record.verify_email!
    end

    succeed "Successfully verified #{records.count} #{'email'.pluralize(records.count)}"
  end
end 