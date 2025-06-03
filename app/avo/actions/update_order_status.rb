class Avo::Actions::UpdateOrderStatus < Avo::BaseAction
  self.name = "Update order status"
  self.visible = -> do
    true
  end

  def fields
    field :status, as: :select, options: Order::STATUSES.transform_keys { |k| [k.to_s.humanize, k] }.to_h, required: true
  end

  def handle(**args)
    records.each do |record|
      record.update(status: args[:status])
    end

    succeed "Successfully updated status for #{records.count} #{'order'.pluralize(records.count)}"
  end
end 