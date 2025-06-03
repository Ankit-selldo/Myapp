class Avo::Filters::CategoryFilter < Avo::Filters::SelectFilter
  self.name = "Category"

  def apply(request, query, value)
    query.where(category: value)
  end

  def options
    Product::CATEGORIES.transform_keys { |k| [k.titleize, k] }.to_h
  end
end 