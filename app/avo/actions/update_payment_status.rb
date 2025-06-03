class Avo::Actions::UpdatePaymentStatus < Avo::BaseAction
  self.name = "Update payment status"
  self.visible = -> do
    true
  end

  def fields
    field :payment_status, as: :select, options: Order::PAYMENT_STATUSES.transform_keys { |k| [k.to_s.humanize, k] }.to_h, required: true
  end

  def handle(**args)
    records.each do |record|
      record.update(payment_status: args[:payment_status])
    end

    succeed "Successfully updated payment status for #{records.count} #{'order'.pluralize(records.count)}"
  end
end 