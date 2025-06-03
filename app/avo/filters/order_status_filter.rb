class Avo::Filters::OrderStatusFilter < Avo::Filters::SelectFilter
  self.name = "Order Status"

  def apply(request, query, value)
    query.where(status: value)
  end

  def options
    Order::STATUSES.transform_keys { |k| [k.to_s.humanize, k] }.to_h
  end
end 