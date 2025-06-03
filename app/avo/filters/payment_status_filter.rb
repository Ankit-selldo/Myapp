class Avo::Filters::PaymentStatusFilter < Avo::Filters::SelectFilter
  self.name = "Payment Status"

  def apply(request, query, value)
    query.where(payment_status: value)
  end

  def options
    Order::PAYMENT_STATUSES.transform_keys { |k| [k.to_s.humanize, k] }.to_h
  end
end 