class Avo::Filters::BlogPostCategoryFilter < Avo::Filters::SelectFilter
  self.name = "Category"

  def apply(request, query, value)
    query.where(category: value)
  end

  def options
    (BlogPost::CATEGORIES + BlogPost::ADDITIONAL_CATEGORIES).map { |c| [c, c] }.to_h
  end
end 