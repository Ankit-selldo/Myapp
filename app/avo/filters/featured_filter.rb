class Avo::Filters::FeaturedFilter < Avo::Filters::BooleanFilter
  self.name = "Featured"

  def apply(request, query, value)
    return query unless value.present?
    query.where(featured: value)
  end

  def options
    {
      true: "Featured",
      false: "Not Featured"
    }
  end
end 