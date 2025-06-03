class Avo::Filters::ProductVariantStockFilter < Avo::Filters::BaseFilter
  self.name = "Stock Status"
  self.visible = true

  def apply(request, query, values)
    return query if values.blank?

    case values.first
    when "in_stock"
      query.where("inventory_count > ?", 0)
    when "out_of_stock"
      query.where(inventory_count: 0)
    when "low_stock"
      query.where("inventory_count > ? AND inventory_count <= ?", 0, 10)
    else
      query
    end
  end

  def options
    {
      "in_stock" => "In Stock",
      "out_of_stock" => "Out of Stock",
      "low_stock" => "Low Stock (≤ 10)"
    }
  end
end 