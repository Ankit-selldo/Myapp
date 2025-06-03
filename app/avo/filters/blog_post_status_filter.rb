class Avo::Filters::BlogPostStatusFilter < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(request, query, value)
    query.where(status: value)
  end

  def options
    {
      draft: "Draft",
      published: "Published",
      archived: "Archived"
    }
  end
end 